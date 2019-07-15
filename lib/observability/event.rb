# -*- ruby -*-
# frozen_string_literal: true

require 'loggability'

require 'observability' unless defined?( Observability )


class Observability::Event
	extend Loggability


	# Loggability API -- send logs to the top-level module's logger
	log_to :observability


	### Create a new event
	def initialize
		
	end


end # class Observability::Event

