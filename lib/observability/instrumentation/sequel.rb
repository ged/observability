# -*- ruby -*-
# frozen_string_literal: true

require 'observability/instrumentation' unless defined?( Observability::Instrumentation )


# Instrumentation for the Sequel database toolkit.
# Refs:
# - http://sequel.jeremyevans.net/
module Observability::Instrumentation::Sequel
	extend Observability::Instrumentation

	depends_on 'Sequel::Database'


	when_installed( 'Sequel::Database' ) do
		Sequel::Database.extend( Observability )
		Sequel::Database.observe_class_method( :connect )
		Sequel::Database.observe_method( :disconnect )
	end


	when_installed( 'Sequel::Postgres::Adapter' ) do
		Sequel::Postgres::Adapter.extend( Observability )
		Sequel::Postgres::Adapter.observe_method( :execute, timed: true ) do |sql, *|
			begin
				nsql = PgQuery.normalize( sql )
				Observability.observer.add( query: nsql )
			rescue => err
				Loggability[ Observability ].warn "Couldn't normalize query: %p" % [ sql ]
			end
		end
	end

end # module Observability::Instrumentation::Sequel

