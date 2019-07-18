# -*- ruby -*-
# frozen_string_literal: true

require 'observability/sender' unless defined?( Observability::Sender )


# A sender that just logs events to the Observability logger.
class Observability::Sender::Logger < Observability::Sender
	extend Loggability


	# Loggability API
	log_as :observability_events


	### Look up the logger that'll be used.
	def initialize( * )
		super
		@logger = Loggability[ self ]
	end


	######
	public
	######

	##
	# The Loggability::Logger that will be used as the event sink
	attr_accessor :logger


	### Output the +event+ to the logger.
	def send_event( event )
		self.logger.debug( event.to_h )
	end

end # class Observability::Sender::Log


