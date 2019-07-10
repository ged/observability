# -*- ruby -*-
# frozen_string_literal: true


# A mixin that adds effortless Observability to your systems.
module Observability

	# Package version
	VERSION = '0.0.1'

	# Version control revision
	REVISION = %q$Revision$


	begin
		require 'configurability'
	rescue LoadError
		# Configurability is optional
	end


	if defined?( Configurability )
		extend Configurability
		configurability( :observability ) do

			##
			# The host to send events to
			setting :host, default: 'localhost'


			##
			# The port to send events to
			setting :port, default: 15663

		end
	else
		class << self
			attr_accessor :host, :port
		end
	end


	autoload :Observer, 'observability/observer'



	### Extension callback
	def self::extended( mod )
		super

		observer = ObserverHooks.dup
		mod.instance_variable_set( :@observer, observer )
		mod.prepend( observer )
	end


	### Return the current Observer, creating it if necessary.
	def self::observer
		return @observer ||= Observability::Observer.new
	end


	### (Undocumented)
	def observe( method_name, *args )
		
		Observability.observer
	end


	# A mixin that allows events to be created for any current observers at runtime.
	module ObserverHooks

		### Return a proxy for all currently-registered observers.
		def observer
			return Observability.observer
		end


		### Create an event at the current point of execution, make it the innermost
		### context, then yield to the method's block. Finish the event when the yield
		### returns, handling exceptions that are being raised automatically.
		def observe( *args )
			yield
		rescue Exception => err
			self.observer.add( err )
			raise
		end

	end

end # module Observability

