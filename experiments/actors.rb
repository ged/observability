#!/usr/bin/env ruby

require 'socket'
require 'msgpack'
require 'loggability'
require 'concurrent'
require 'concurrent-edge'

Concurrent.extend( Loggability )
Concurrent.log_as( :concurrent )
Concurrent.global_logger = ->( severity, progname, message=nil, &block ) do
	Loggability[ Concurrent ].add( severity, message, progname, &block )
end

class Sender < Concurrent::Actor::Context
	extend Loggability
	log_to :concurrent

	def initialize( host, port )
		super()

		@host = host
		@port = port

		@socket = UDPSocket.new
	end

	attr_reader :host, :port, :socket

	def default_executor
		return Concurrent.global_io_executor
	end

	def on_message( serialized_event )
		self.log.debug "Sending message to %s:%d" % [ self.host, self.port ]
		self.socket.send( serialized_event, 0, self.host, self.port )
	end

end


class Serializer < Concurrent::Actor::Context
	extend Loggability
	log_to :concurrent

	def initialize( host, port )
		super()
		@sender = Sender.spawn( name: :sender, link: true, args: [host, port] )
	end

	attr_reader :sender

	def on_message( event_data )
		serialized_event = MessagePack.pack( event_data )
		self.sender << serialized_event
	end

end


class Observer < Concurrent::Actor::RestartingContext
	extend Loggability
	log_to :concurrent

	def initialize( host='localhost', port=13786 )
		super()
		@serializer = Serializer.spawn( name: :serializer, link: true, args: [@host, @port] )
	end

	attr_reader :serializer

	def on_message( message, *data )
		case message
		when :event
			self.serializer << { type: 'event', data: data }
		end
	end

end


class Sink < Concurrent::Actor::Context
	extend Loggability
	log_to :concurrent

	def initialize( host='localhost', port=13786 )
		self.log.info "Spawning a Sink"
		super()
		@host = host
		@port = port
		@socket = UDPSocket.new
		@running = false
		@io_thread = nil
	end

	attr_reader :host, :port
	attr_accessor :running


	def default_executor
		return Concurrent.global_io_executor
	end


	def on_message( message )
		case message
		when :start_listening
			self.start_listening
		when :stop_listening
			self.stop_listening
		else
			pass
		end
	end


	def start_listening
		@io_thread = Thread.new do
			Thread.report_on_exception = true
			self.running = true

			@socket.bind( self.host, self.port )

			while self.running
				self.log.info "IO loop; running = %p" % [ self.running ]
				readable, _, _ = IO.select( [@socket], nil, nil, 0.5 )
				if readable
					msg, addr, flags = @socket.recvmsg
					event = MessagePack.unpack( msg )
					self.log.warn "Event: %p from %s" % [ event, addr.ip_address ]
				end
			end

			self.log.info "Sink: Exiting server loop."
		end
	end


	def stop_listening
		self.log.info "Stopping..."
		self.running = false
		self.log.debug "Running = %p" % [ self.running ]
	end

end

Loggability.level = :debug
Loggability.format_with( :color )
logger = Loggability.logger
logger.info "Starting the sink."

sink = Sink.spawn( name: :sink )
sink.ask( :start_listening )

sleep 3

logger.info "Started. Starting the observer and sending an event."

observer = Observer.spawn( name: :observer )
observer << [ :event, "Something" ]

logger.info "Done. Waiting a few seconds."

sleep 3

logger.info "Stopping the sink."

sink.tell( :stop_listening )
sink.ask( :await ).wait

logger.info "Done."


