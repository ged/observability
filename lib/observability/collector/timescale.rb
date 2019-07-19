# -*- ruby -*-
# frozen_string_literal: true

require 'sequel'
require 'configurability'

require 'observability/collector' unless defined?( Observability::Collector )


class Observability::Collector::Timescale < Observability::Collector
	extend Configurability


	configurability( 'observability.collector.udp' ) do

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

		@socket = UDPSocket.new
		@db = nil
	end


	######
	public
	######

	##
	# The socket to read events from
	attr_reader :socket



	### Start receiving events.
	def start
		@db = Sequel.connect( self.class.db )
	end


	### Read the next event from the socket
	def read_next_event
		@
	end

end # class Observability::Collector::UDP

