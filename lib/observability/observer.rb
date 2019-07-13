# -*- ruby -*-
# frozen_string_literal: true

require 'loggability'
require 'observability' unless defined?( Observability )


class Observability::Observer
	extend Loggability

	# Log to Observability's internal logger
	log_to :observability


	### Create a new Observer that will send events via the specified +sender+.
	def initialize( sender )
		@sender = sender
	end


	### Add +args+ to the current observation.
	def add( *args )
		self.log.warn "Adding %p" % [ args ]
	end

end # class Observability::Observer

