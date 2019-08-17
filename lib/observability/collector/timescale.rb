# -*- ruby -*-
# frozen_string_literal: true

require 'sequel'
require 'configurability'

require 'observability/collector' unless defined?( Observability::Collector )


class Observability::Collector::Timescale < Observability::Collector
	extend Configurability,
		Loggability

	Sequel.extension( :pg_json )


	# The maximum size of event messages
	MAX_EVENT_BYTES = 64 * 1024

	# The number of seconds to wait between IO loops
	LOOP_TIMER = 0.25

	# The config to pass to JSON.parse
	JSON_CONFIG = {
		object_class: Sequel::Postgres::JSONHash,
		array_class: Sequel::Postgres::JSONArray
	}.freeze


	log_to :observability

	configurability( 'observability.collector.timescale' ) do

		##
		# The local address to bind to
		setting :bind_address, default: '0.0.0.0'

		##
		# The address of the multicast group to join
		setting :multicast_address, default: '224.15.7.75'

		##
		# The TTL of the outgoing messages, i.e., how many hops they will be limited to
		setting :multicast_ttl, default: 1

		##
		# The port to bind to
		setting :port, default: 15775

		##
		# The URL of the timescale DB to store events in
		setting :db, default: 'postgres:/observability'
	end


	### Return an IPAddr that represents the local + multicast addresses to bind to.
	def self::bind_addr
		return IPAddr.new( self.bind_address ).hton + IPAddr.new( self.multicast_address ).hton
	end


	### Create a new UDP sender
	def initialize( * )
		super

		@multicast_address = self.class.multicast_address
		@port              = self.class.port
		@socket            = self.create_socket
		@db                = nil
		@cursor            = nil
		@processing        = false
	end


	######
	public
	######

	##
	# The address of the multicast group to send to
	attr_reader :multicast_address

	##
	# The port to send on
	attr_reader :port

	##
	# The socket to send events over
	attr_reader :socket

	##
	# The database handle to use when inserting events
	attr_reader :db


	### Start receiving events.
	def start
		self.log.info "Starting up."
		@db = Sequel.connect( self.class.db )
		@db.extension( :pg_json )

		self.socket.bind( self.class.bind_address, self.class.port )

		self.start_processing
	end


	### Stop receiving events.
	def stop
		self.stop_processing

		self.db.disconnect
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
		data = self.socket.recv_nonblock( MAX_EVENT_BYTES, exception: false )

		if data == :wait_readable
			IO.select( [self.socket], nil, nil, LOOP_TIMER )
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
		time    = event.delete('@timestamp')
		type    = event.delete('@type')
		version = event.delete('@version')

		# @cursor.call( time: time, type: type, version: version, data: event )
		self.db[ :events ].insert(
			 time: time,
			 type: type,
			 version: version,
			 data: Sequel.pg_json( event )
		)
	end


	### Create and return a UDPSocket after setting it up for multicast.
	def create_socket
		iaddr = self.class.bind_addr
		socket = UDPSocket.new

		socket.setsockopt( :IPPROTO_IP, :IP_ADD_MEMBERSHIP, iaddr )
		socket.setsockopt( :IPPROTO_IP, :IP_MULTICAST_TTL, self.class.multicast_ttl )
		socket.setsockopt( :IPPROTO_IP, :IP_MULTICAST_LOOP, 1 )
		socket.setsockopt( :SOL_SOCKET, :SO_REUSEPORT, 1 )

		return socket
	end

end # class Observability::Collector::UDP

