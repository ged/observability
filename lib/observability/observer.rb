# -*- ruby -*-
# frozen_string_literal: true

require 'loggability'
require 'observability' unless defined?( Observability )


class Observability::Observer
	extend Loggability

	# Log to Observability's internal logger
	log_to :observability


	### Create a new Observer that will send events via the specified +sender+.
	def initialize( sender_class )
		@sender = sender_class.new
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
	def add( *args )
		self.log.warn "Adding %p" % [ args ]
	end

end # class Observability::Observer

