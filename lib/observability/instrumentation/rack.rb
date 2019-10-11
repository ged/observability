# -*- ruby -*-
# frozen_string_literal: true

require 'observability/instrumentation' unless defined?( Observability::Instrumentation )


# Instrumentation for the Rack HTTP interface library
# Refs:
# - https://rack.github.io
module Observability::Instrumentation::Rack
	extend Observability::Instrumentation

	depends_on 'Rack'


	when_installed( 'Rack::Builder' ) do
		Rack::Builder.extend( Observability )
		Rack::Builder.observe_method( :call )
	end


end # module Observability::Instrumentation::Rack

