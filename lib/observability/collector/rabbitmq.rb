# -*- ruby -*-
# frozen_string_literal: true

require 'json'
require 'configurability'
require 'bunny'

require 'observability/collector' unless defined?( Observability::Collector )


# A collector that re-injects events over AMQP to a RabbitMQ cluster.
class Observability::Collector::RabbitMQ < Observability::Collector
	extend Configurability,
		Loggability

	# The maximum size of event messages
	MAX_EVENT_BYTES = 64 * 1024

	# The number of seconds to wait between IO loops
	LOOP_TIMER = 0.25

	# Default options for publication
	DEFAULT_PUBLISH_OPTIONS = {
		mandatory:  false,
		persistent: true
	}


	log_to :observability

	configurability( 'observability.collector.rabbitmq' ) do

		##
		# The host to bind to
		setting :host, default: 'localhost'

		##
		# The port to bind to
		setting :port, default: 15775

		##
		# The broker_uri to use when connecting to RabbitMQ
		setting :broker_uri

		##
		# The exchange to use when connecting to RabbitMQ
		setting :exchange, default: 'events'

		##
		# The vhost to use when connecting to RabbitMQ
		setting :vhost, default: '/telemetry'

		##
		# The heartbeat to use when connecting to RabbitMQ
		setting :heartbeat, default: 'server' do |value|
			value.to_sym if value
		end

		##
		# Use single-threaded connections when set to `false`
		setting :threaded, default: false

	end


	### Fetch a Hash of AMQP options.
	def self::amqp_session_options
		return {
			logger: Loggability[ Observability ],
			heartbeat: self.heartbeat,
			exchange: self.exchange,
			vhost: self.vhost,
			threaded: self.threaded,
		}
	end


	### Return a formatted list of the server's capabilities listed in +server_info+.
	def self::capabilities_list( server_info )
		server_info.
			map {|name,enabled| enabled ? name : nil }.
			compact.join(', ')
	end


	### Establish the connection to RabbitMQ based on the loaded configuration.
	def self::configured_amqp_session
		uri = self.broker_uri or raise "No broker_uri configured."
		options = self.amqp_session_options

		session = Bunny.new( uri, options )
		session.start

		self.log.info "Connected to %s v%s server: %s" % [
			session.server_properties['product'],
			session.server_properties['version'],
			self.capabilities_list( session.server_properties['capabilities'] ),
		]

		return session
	end



	### Create a new UDP collector
	def initialize
		super

		@socket        = UDPSocket.new
		@amqp_session  = nil
		@amqp_channel  = Concurrent::ThreadLocalVar.new { @amqp_session.create_channel }
		@amqp_exchange = Concurrent::ThreadLocalVar.new do
			@amqp_channel.value.headers( self.class.exchange, passive: true )
		end
		@processing    = false
	end


	######
	public
	######

	### Start receiving events.
	def start
		self.log.info "Starting up."

		@amqp_session = self.class.configured_amqp_session
		@socket.bind( self.class.host, self.class.port )

		self.start_processing
	end


	### Stop receiving events.
	def stop
		self.stop_processing

		@socket.shutdown( :SHUT_RDWR )
		@amqp_session.close
	end


	### Start consuming incoming events and storing them.
	def start_processing
		@processing = true
		while @processing
			event = self.read_next_event or next
			self.log.debug "Read event: %p" % [ event ]
			self.store_event( event )
		end
	end


	### Stop consuming events.
	def stop_processing
		@processing = false
	end


	### Read the next event from the socket
	def read_next_event
		self.log.debug "Reading next event."
		data = @socket.recv_nonblock( MAX_EVENT_BYTES, exception: false )

		if data == :wait_readable
			IO.select( [@socket], nil, nil, LOOP_TIMER )
			return nil
		elsif data.empty?
			return nil
		else
			self.log.info "Read %d bytes" % [ data.bytesize ]
			return JSON.parse( data )
		end
	end


	### Store the specified +event+.
	def store_event( event )
		time    = event.delete( '@timestamp' )
		type    = event.delete( '@type' )
		version = event.delete( '@version' )

		data = JSON.generate( event )
		headers = {
			time: time,
			type: type,
			version: version,
			content_type: 'application/json',
			content_encoding: data.encoding.name,
			timestamp: Time.now.to_f,
		}

		@amqp_exchange.value.publish( data, headers )
	end

end # class Observability::Collector::RabbitMQ
