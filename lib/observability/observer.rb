# -*- ruby -*-
# frozen_string_literal: true

require 'loggability'
require 'observability' unless defined?( Observability )


class Observability::Observer
	extend Loggability


	log_to :observability


	### Add +args+ to the current observation.
	def add( *args )
		self.log.warn "Adding %p" % [ args ]
	end

end # class Observability::Observer

