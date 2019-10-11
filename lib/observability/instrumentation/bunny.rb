# -*- ruby -*-
# frozen_string_literal: true

require 'observability/instrumentation' unless defined?( Observability::Instrumentation )


# Instrumentation for the Bunny RabbitMQ client library
# Refs:
# - http://rubybunny.info/
module Observability::Instrumentation::Bunny
	extend Observability::Instrumentation

	depends_on 'Bunny'


	when_installed( 'Bunny::Session' ) do
		Bunny::Session.extend( Observability )
		Bunny::Session.observe_class_method( :new )
		Bunny::Session.observe_method( :start )
	end


end # module Observability::Instrumentation::Bunny

