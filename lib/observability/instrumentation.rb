# -*- ruby -*-
# frozen_string_literal: true

require 'set'
require 'observability' unless defined?( Observability )


# Utilities for loading and installing pre-packaged instrumentation for common
# libraries.
module Observability::Instrumentation

	### Load instrumentation for the specified +libraries+.
	def self::load( *libraries )
		libraries.flatten.each do |library|
			libfile = "observability/instrumentation/%s" % [ library ]
			require( libfile )
		end

		return self
	end


	### Extension callback -- declare some instance variables in the extending
	### +mod+.
	def self::extended( mod )
		super

		mod.instance_variable_set( :@depends_on, Set.new )
		mod.instance_variable_set( :@installation_callbacks, Set.new )
	end


	##
	# :singleton-method:
	# The Set of modules + callback tuples which install the instrumentation
	singleton_class.attr_reader :installation_callbacks


	### Install loaded instrumentation if the requisite modules are present.
	def self::install
		self.call_installation_callbacks if self.depended_modules_present?
	end


	### Returns +true+ if all the module dependencies declared using ::depends_on
	### are defined.
	def self::depended_modules_present?
		
	end


	### Declare +modules+ that must be available for instrumentation to be loaded.
	### If they are not present when the instrumentation loads, it will be skipped
	### entirely.
	def depends_on( *modules )
		@depends_on.merge( modules.flatten(1) )
		return @depends_on
	end


	### Register a +callback+ that will be called when instrumentation is installed,
	### if and only if all of the given +modules+ are present (may be empty).
	def when_installed( *modules, &callback )
		@installation_callbacks.add( [modules, callback] )
	end


	


end # module Observability::Instrumentation

