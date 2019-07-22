# -*- ruby -*-
# frozen_string_literal: true

require 'observability' unless defined?( Observability )


# A mixin that allows events to be created for any current observers at runtime.
module Observability::ObserverHooks

	### Create an event at the current point of execution, make it the innermost
	### context, then yield to the method's block. Finish the event when the yield
	### returns, handling exceptions that are being raised automatically.
	def observe( detail, **options, &block )
		raise LocalJumpError, "no block given" unless block

		marker = Observability.observer.event( [block, detail], **options )
		Observability.observer.finish_after_block( marker, &block )
	end


	### Return the current Observability observer agent.
	def observability
		return Observability.observer
	end

end # module Observability::ObserverHooks


