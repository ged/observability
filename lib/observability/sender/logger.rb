# -*- ruby -*-
# frozen_string_literal: true

require 'observability/sender' unless defined?( Observability::Sender )


# A sender that just logs events to the Observability logger.
class Observability::Sender::Logger < Observability::Sender
	extend Loggability


	# Loggability API
	log_as :observability_events


	### Output the +event+ to the logger.
	def send_event( event )
		self.logger.debug( event.resolve )
	end

end # class Observability::Sender::Log


