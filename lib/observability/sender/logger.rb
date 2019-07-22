# -*- ruby -*-
# frozen_string_literal: true

require 'observability/sender' unless defined?( Observability::Sender )


# A sender that just logs events to the Observability logger.
class Observability::Sender::Logger < Observability::Sender
	extend Loggability


	# Loggability API
	log_as :observability_events


	def start # :nodoc:
		# No-op
	end


	def stop # :nodoc:
		# No-op
	end


	### Output the +event+ to the logger.
	def enqueue( *events )
		events.each do |event|
			self.log.debug( event.resolve )
		end
	end

end # class Observability::Sender::Log


