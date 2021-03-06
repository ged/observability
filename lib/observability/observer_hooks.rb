# -*- ruby -*-
# frozen_string_literal: true

require 'observability' unless defined?( Observability )


# A mixin that allows events to be created for any current observers at runtime.
module Observability::ObserverHooks

	### Create an event at the current point of execution, make it the innermost
	### context, then yield to the method's block. Finish the event when the yield
	### returns, handling exceptions that are being raised automatically.
	def observe( detail, **options, &block )
		if block
			marker = Observability.observer.event( [block, detail], **options )
			Observability.observer.finish_after_block( marker, &block )
		else
			Loggability[ Observability ].warn "No block given for %p -> %p with options: %p" %
				[ self, detail, options ]
		end
	end


	### Return the current Observability observer agent.
	def observability
		return Observability.observer
	end

end # module Observability::ObserverHooks


