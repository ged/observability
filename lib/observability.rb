# -*- ruby -*-
# frozen_string_literal: true

require 'loggability'


# A mixin that adds effortless Observability to your systems.
module Observability
	extend Loggability


	# Package version
	VERSION = '0.0.1'

	# Version control revision
	REVISION = %q$Revision$


	log_as :observability


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


	@observer_hooks = {}
	singleton_class.attr_reader :observer_hooks


	### Extension callback
	def self::extended( mod )
		super

		Observability.observer_hooks[ mod ] ||= begin
			observer_hooks = ObserverHooks.dup
			observer_hooks.observed_system = mod.name || '<anonymous:%#x>' % [mod.object_id * 2]
			mod.prepend( observer_hooks )
			observer_hooks
		end
	end


	### Return the current Observer, creating it if necessary.
	def self::observer
		return @observer ||= Observability::Observer.new
	end


	### Make the method body for an observation method for the method with the given
	### +name+.
	def self::make_observer_method( name, description, **options )
		return lambda do |*method_args, **method_options, &block|
			Observability.observer.add( name, description, options )
			super( *method_args, **method_options, &block )
		end
	end


	### Set the +description+ of the observed system for the receiver.
	def observed_system( description )
		Observability.observer_hooks[ self ]&.description = description
	end


	### Wrap a method call in an observer call.
	def observe( method_name, description=nil, **options )
		hooks = Observability.observer_hooks[ self ] or
			raise "No observer hooks installed for %p?!" % [ self ]
		method_body = Observability.make_observer_method( method_name, description, **options )

		hooks.define_method( method_name, &method_body )
	end


	# A mixin that allows events to be created for any current observers at runtime.
	module ObserverHooks

		singleton_class.attr_accessor :observed_system


		### Set up the event stack for each object.
		def initialize( * )
			super if defined?( super )
			@observability_event_stack = []
		end


		##
		# The stack of events which are being built, outermost-first
		attr_reader :observability_event_stack


		### Return a proxy for all currently-registered observers.
		def observer
			return Observability.observer
		end


		### Create an event at the current point of execution, make it the innermost
		### context, then yield to the method's block. Finish the event when the yield
		### returns, handling exceptions that are being raised automatically.
		def observe( *args )
			event = Observability::Event.new
			self.observability_event_stack.push( event )
			yield
		rescue Exception => err
			self.observer.add( err )
			raise
		end

	end

end # module Observability

