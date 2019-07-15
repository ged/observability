# -*- ruby -*-
# frozen_string_literal: true

require 'observability/sender' unless defined?( Observability::Sender )


# A Sender that no-ops all observation routines. This effectively disables
# Observability.
class Observability::Sender::Null < Observability::Sender

	### Overridden: Nothing to start.
	def start
		# No-op
	end


	### Overridden: Nothing to stop.
	def stop
		# No-op
	end


	### Overridden: Drop enqueued events.
	def enqueue( * )
		# No-op
	end

end # class Observability::Sender::Null


