# -*- ruby -*-
# frozen_string_literal: true

require 'set'
require 'loggability'

require 'observability' unless defined?( Observability )


# Utilities for loading and installing pre-packaged instrumentation for common
# libraries.
module Observability::Instrumentation
	extend Loggability


	# Loggability API -- use the Observability logger for instrumentation
	log_to :observability


	##
	# :singleton-method:
	# The Set of Instrumentation modules that are laoded
	singleton_class.attr_reader :modules
	@modules = Set.new


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

		if self.modules.add?( mod )
			self.log.info "Loaded %p" % [ mod ]
			mod.extend( Loggability )
			mod.log_to( :observability )
			mod.instance_variable_set( :@depends_on, Set.new )
			mod.instance_variable_set( :@installation_callbacks, Set.new )
			mod.singleton_class.attr_reader( :installation_callbacks )
		else
			self.log.warn "Already loaded %p" % [ mod ]
		end
	end


	### Install loaded instrumentation if the requisite modules are present.
	def self::install
		self.modules.each do |mod|
			mod.install if mod.available?
		end
	end


	### Returns +true+ if each of the given +module_names+ are defined and are
	### Module objects.
	def self::dependencies_met?( *module_names )
		return module_names.flatten.all? do |mod|
			self.check_for_module( mod )
		end
	end


	### Returns +true+ if +mod+ is defined and is a Module.
	def self::check_for_module( mod )
		self.log.debug "Checking for presence of `%s` module..." % [ mod ]
		Object.const_defined?( mod ) && Object.const_get( mod ).is_a?( Module )
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
		self.installation_callbacks.add( [callback, modules] )
	end


	### Returns +true+ if all of the modules registered with #depends_on are defined.
	def available?
		return Observability::Instrumentation.dependencies_met?( self.depends_on.to_a )
	end


	### Call installation callbacks which meet their prerequistes.
	def install
		self.installation_callbacks.each do |callback, dependencies|
			missing = dependencies.
				reject {|mod| Observability::Instrumentation.check_for_module(mod) }

			if missing.empty?
				self.log.debug "Instrumenting %s: %p" % [ dependencies.join(', '), callback ]
				callback.call
			else
				self.log.info "Skipping %p: missing %s" % [ callback, missing.join(', ') ]
			end
		end
	end

end # module Observability::Instrumentation

