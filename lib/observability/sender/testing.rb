# -*- ruby -*-
# frozen_string_literal: true

require 'loggability'

require 'observability/sender' unless defined?( Observability::Sender )


# A sender that just enqueues events and then lets you make assertions about the
# kinds of events that were sent.
class Observability::Sender::Testing < Observability::Sender
	extend Loggability


	# Loggability API
	log_to :observability


	### Create a new testing sender.
	def initialize( * )
		@enqueued_events = []
	end


	##
	# The Array of events which were queued.
	attr_reader :enqueued_events


	# No-ops; there is no sending thread, so nothing to start/stop.
	def start( * ); end
	def stop( * ); end


	### Sender API -- add the specified +events+ to the queue.
	def enqueue( *events )
		@enqueued_events.concat( events )
	end


	### Return any enqueued events that are of the specified +type+.
	def find_events( type )
		return @enqueued_events.find_all do |event|
			event.type == type
		end
	end

	### Returns +true+ if at least one event of the specified +type+ was enqueued.
	def event_was_sent?( type )
		return !self.find_events( type ).empty?
	end

end # class Observability::Sender::Testing


