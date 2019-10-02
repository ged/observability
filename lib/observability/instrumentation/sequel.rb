# -*- ruby -*-
# frozen_string_literal: true

require 'observability/instrumentation' unless defined?( Observability::Instrumentation )


# Instrumentation for the Sequel database toolkit.
# Refs:
# - http://sequel.jeremyevans.net/
module Observability::Instrumentation::Sequel
	extend Observability::Instrumentation


	when_installed( depends_on: :Sequel => 'sequel' ) do
		unless defined?( Sequel )
			self.log.info "Not instrumenting Sequel: not loaded!"
			return
		end

		return if Sequel::Database < Observability

		self.log.warn "Instrumenting Sequel..."
		Sequel::Database.extend( Observability )
		Sequel::Database.observe_class_method( :connect )
		Sequel::Database.observe_method( :disconnect )
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

