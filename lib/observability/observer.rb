# -*- ruby -*-
# frozen_string_literal: true

require 'concurrent'
require 'loggability'

require 'observability' unless defined?( Observability )


class Observability::Observer
	extend Loggability


	# The default type of sender to construct
	DEFAULT_SENDER_TYPE = :null


	# Log to Observability's internal logger
	log_to :observability


	### Create a new Observer that will send events via the specified +sender+.
	def initialize( sender_type=DEFAULT_SENDER_TYPE )
		@sender = Observability::Sender.create( sender_type )
		@event_stack = Concurrent::ThreadLocalVar.new( &Array.method(:new) )
	end


	######
	public
	######

	##
	# The Observability::Sender used to deliver events
	attr_reader :sender


	### Start recording events and sending them.
	def start
		self.sender.start
	end


	### Stop recording and sending events.
	def stop
		self.sender.stop
	end


	### Add +args+ to the current observation.
	def add( **fields )
		self.log.warn "Adding %p" % [ args ]
		event = @event_stack.value.last or return
		event.merge( fields )
	end


	### (Undocumented)
	def new_event( )
		
	end

end # class Observability::Observer

