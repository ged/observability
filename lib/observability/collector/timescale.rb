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
		# The host to bind to
		setting :host, default: 'localhost'

		##
		# The port to bind to
		setting :port, default: 15775

		##
		# The URL of the timescale DB to store events in
		setting :db, default: 'postgres:/observability'
	end


	### Create a new UDP collector
	def initialize
		super

		@socket     = UDPSocket.new
		@db         = nil
		@cursor     = nil
		@processing = false
	end


	######
	public
	######

	### Start receiving events.
	def start
		self.log.info "Starting up."
		@db = Sequel.connect( self.class.db )
		@db.extension( :pg_json )
		# @cursor = @db[ :events ].prepare( :insert, :insert_new_event,
		# 	 time: :$time,
		# 	 type: :$type,
		# 	 version: :$version,
		# 	 data: :$data
		# )

		@socket.bind( self.class.host, self.class.port )

		self.start_processing
	end


	### Stop receiving events.
	def stop
		self.stop_processing

		@cursor = nil
		@db.disconnect
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
		time    = event.delete('@timestamp')
		type    = event.delete('@type')
		version = event.delete('@version')

		# @cursor.call( time: time, type: type, version: version, data: event )
		@db[ :events ].insert(
			 time: time,
			 type: type,
			 version: version,
			 data: Sequel.pg_json( event )
		)
	end

end # class Observability::Collector::UDP

