# -*- ruby -*-
# frozen_string_literal: true

require 'observability/instrumentation' unless defined?( Observability::Instrumentation )


# Instrumentation for the 'pg' PostgreSQL driver
# Refs:
# - https://github.com/ged/ruby-pg
module Observability::Instrumentation::PG
	extend Observability::Instrumentation

	depends_on 'PG'

	requires 'pg_query'

	when_installed( 'PG::Connection' ) do
		PG::Connection.extend( Observability )
		PG::Connection.observe_class_method( :connect_start )
		PG::Connection.observe_class_method( :ping, timed: true )
		PG::Connection.observe_method( :connect_poll )
		PG::Connection.observe_method( :reset )
		PG::Connection.observe_method( :reset_start )
		PG::Connection.observe_method( :reset_poll )
		PG::Connection.observe_method( :sync_exec )
		PG::Connection.observe_method( :finish )

		PG::Connection.observe_method( :exec, timed: true, &self.method(:observe_exec) )
		PG::Connection.observe_method( :exec_params, timed: true, &self.method(:observe_exec) )

		PG::Connection.observe_method( :sync_exec, timed: true, &self.method(:observe_exec) )
		PG::Connection.observe_method( :sync_exec_params, timed: true, &self.method(:observe_exec) )

		PG::Connection.observe_method( :prepare, timed: true, &self.method(:observe_prepare) )
		PG::Connection.observe_method( :exec_prepared, timed: true, &self.method(:observe_exec_prepared) )

		PG::Connection.observe_method( :sync_prepare, timed: true, &self.method(:observe_prepare) )
		PG::Connection.observe_method( :sync_exec_prepared, timed: true, &self.method(:observe_exec_prepared) )
	end


	### Observer callback for the *exec methods.
	def observe_exec( sql, * )
		nsql = PgQuery.normalize( sql )
		Observability.observer.add( query: nsql )
	rescue => err
		Loggability[ Observability ].warn "Couldn't normalize query: %p" % [ sql ]
	end


	### Observer callback for *prepare methods.
	def observe_prepare( name, query, * )
		nsql = PgQuery.normalize( query )
		Observability.observer.add( statement_name: name, query: nsql )
	rescue => err
		Loggability[ Observability ].warn "Couldn't normalize query: %p" % [ sql ]
	end


	### Observer callback for *exec_prepared methods.
	def observe_exec_prepared( name, query, * )
		Observability.observer.add( statement_name: name )
	end

end # module Observability::Instrumentation::PG

