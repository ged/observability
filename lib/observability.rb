# -*- ruby -*-
# frozen_string_literal: true

require 'concurrent'
require 'concurrent/configuration'
require 'configurability'
require 'loggability'


# A mixin that adds effortless Observability to your systems.
module Observability
	extend Loggability


	# Package version
	VERSION = '0.1.0'

	# Version control revision
	REVISION = %q$Revision$


	# Loggability -- Create a logger
	log_as :observability
	Concurrent.global_logger = lambda do |loglevel, progname, message=nil, &block|
		Observability.logger.add( loglevel, message, progname, &block )
	end

	autoload :Collector, 'observability/collector'
	autoload :Event, 'observability/event'
	autoload :Instrumentation, 'observability/instrumentation'
	autoload :ObserverHooks, 'observability/observer_hooks'
	autoload :Observer, 'observability/observer'
	autoload :Sender, 'observability/sender'


	@observer_hooks = Concurrent::Map.new
	singleton_class.attr_reader :observer_hooks

	@observer = Concurrent::IVar.new


	### Get the observer hooks for the specified +mod+.
	def self::[]( mod )
		mod = mod.class unless mod.is_a?( Module )
		return self.observer_hooks[ mod ]
	end


	### Extension callback
	def self::extended( mod )
		super

		Observability.observer_hooks.compute_if_absent( mod ) do
			observer_hooks = Observability::ObserverHooks.dup
			mod.prepend( observer_hooks )
			observer_hooks
		end

		mod.singleton_class.extend( Observability ) unless mod.singleton_class?
	end


	### Install the default instrumentatin for one or more +libraries+.
	def self::install_instrumentation( *libraries )
		Observability::Instrumentation.load( *libraries )
		Observability::Instrumentation.install
	end


	### Return the current Observer, creating it if necessary.
	def self::observer
		unless @observer.complete?
			self.log.debug "Creating the observer agent."
			@observer.try_set do
				obs = Observability::Observer.new
				obs.start
				obs
			end
		end

		return @observer.value!
	end


	### Reset all per-process Observability state. This should be called, for instance,
	### after a fork or between tests.
	def self::reset
		@observer.value.stop if @observer.complete?
		@observer = Concurrent::IVar.new
	end


	### Make a body for a wrapping method for the method with the given +name+ and
	### +context+, passing the given +options+.
	def self::make_wrapped_method( name, context, options, &callback )
		return Proc.new do |*m_args, **m_options, &block|
			Loggability[ Observability ].debug "Wrapped method %p: %p" %
				[ name, context ]
			Observability.observer.event( context, **options ) do
				# :TODO: Freeze or dup the arguments to prevent accidental modification?
				callback.call( *m_args, **m_options, &block ) if callback
				super( *m_args, **m_options, &block )
			end
		end
	end

	#
	# DSL Methods
	#

	### Wrap an instance method in an observer call.
	def observe_method( method_name, *details, **options, &callback )
		hooks = Observability.observer_hooks[ self ] or
			raise "No observer hooks installed for %p?!" % [ self ]

		context = self.instance_method( method_name )
		context = [ context, *details ]
		method_body = Observability.make_wrapped_method( method_name, context, options, &callback )

		hooks.define_method( method_name, &method_body )
	end


	### Wrap a class method in an observer call.
	def observe_class_method( method_name, *details, **options, &callback )
		self.singleton_class.observe_method( method_name, *details, **options, &callback )
	end

end # module Observability

