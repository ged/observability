# -*- ruby -*-
# frozen_string_literal: true

require 'observability' unless defined?( Observability )


# A mixin that allows events to be created for any current observers at runtime.
module Observability::ObserverHooks


	singleton_class.attr_accessor( :observed_system )


	### Create an event at the current point of execution, make it the innermost
	### context, then yield to the method's block. Finish the event when the yield
	### returns, handling exceptions that are being raised automatically.
	def observe( *args )
		hooks = Observability[ self ]
		Observability.observer.new_event( hooks.observed_system, *args )
		yield
	rescue Exception => err
		Observability.observer.add( err )
		raise
	ensure
		Observability.observer.finish_event( hooks.observed_system ) if hooks
	end

end # module Observability::ObserverHooks


