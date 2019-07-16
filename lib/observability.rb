# -*- ruby -*-
# frozen_string_literal: true

require 'concurrent'
require 'configurability'
require 'loggability'


# A mixin that adds effortless Observability to your systems.
module Observability
	extend Loggability,
	       Configurability


	# Package version
	VERSION = '0.0.1'

	# Version control revision
	REVISION = %q$Revision$


	# Loggability -- Create a logger
	log_as :observability


	# Configuration settings
	configurability( :observability ) do

		##
		# The sender type to use
		setting :sender_type, default: :null

	end


	autoload :Event, 'observability/event'
	autoload :Observer, 'observability/observer'
	autoload :ObserverHooks, 'observability/observer_hooks'
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
			observer_hooks = ObserverHooks.dup
			observer_hooks.observed_system = mod.name || '<anonymous:%#x>' % [mod.object_id * 2]
			mod.prepend( observer_hooks )
			observer_hooks
		end
	end


	### Return the current Observer, creating it if necessary.
	def self::observer
		unless @observer.complete?
			self.log.debug "Creating the observer agent."
			@observer.try_set do
				sender = Observability::Sender.get_subclass( Observability.sender_type )
				obs = Observability::Observer.new( sender )
				obs.start
				obs
			end
		end

		return @observer.value!
	end


	### Make the method body for an observation method for the method with the given
	### +name+.
	def self::make_observer_method( name, description, **options )
		return lambda do |*method_args, **method_options, &block|
			self.observe( name, description, **options ) do
				super( *method_args, **method_options, &block )
			end
		end
	end


	### Reset all per-process Observability state. This should be called, for instance,
	### after a fork or between tests.
	def self::reset
		@observer.value.stop if @observer.complete?
		@observer = Concurrent::IVar.new
	end


	#
	# DSL Methods
	#

	### Wrap a method call in an observer call.
	def observe( method_name, description=nil, **options )
		hooks = Observability.observer_hooks[ self ] or
			raise "No observer hooks installed for %p?!" % [ self ]
		method_body = Observability.make_observer_method( method_name, description, **options )

		hooks.define_method( method_name, &method_body )
	end


	### Set the +description+ of the observed system for the receiver.
	def observed_system( description )
		Observability.observer_hooks[ self ]&.description = description
	end


end # module Observability

