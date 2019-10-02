# -*- ruby -*-
# frozen_string_literal: true

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


end # module Observability::Instrumentation

