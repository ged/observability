# -*- ruby -*-
# frozen_string_literal: true

require 'observability' unless defined?( Observability )


# A mixin that allows events to be created for any current observers at runtime.
module Observability::ObserverHooks


	##
	# The description of the system the module is mixed into
	attr_accessor :observed_system


	### Return a proxy for all currently-registered observers.
	def observer
		return Observability.observer
	end


	### Create an event at the current point of execution, make it the innermost
	### context, then yield to the method's block. Finish the event when the yield
	### returns, handling exceptions that are being raised automatically.
	def observe( *args )
		self.observer.new_event( *args )
		yield
	rescue Exception => err
		self.observer.add( err )
		raise
	end

end # module Observability::ObserverHooks


