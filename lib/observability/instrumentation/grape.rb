# -*- ruby -*-
# frozen_string_literal: true

require 'observability/instrumentation' unless defined?( Observability::Instrumentation )


# Instrumentation for the Grape HTTP API framework
# Refs:
# - http://www.ruby-grape.org/
module Observability::Instrumentation::Grape
	extend Observability::Instrumentation

	depends_on 'Grape'


	when_installed( 'Grape::API' ) do
		Grape::API.extend( Observability )
		Grape::API.observe_method( :call )
	end

end # module Observability::Instrumentation::Grape

