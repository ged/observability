# -*- ruby -*-
# frozen_string_literal: true

require 'observability/instrumentation' unless defined?( Observability::Instrumentation )


# Instrumentation for the CZTop library
# Refs:
# - https://gitlab.com/paddor/cztop
module Observability::Instrumentation::CZTop
	extend Observability::Instrumentation

	depends_on 'CZTop'


	when_installed( 'CZTop::Socket' ) do
		CZTop::Socket.extend( Observability )
		CZTop::Socket.observe_method( :CURVE_server! )
		CZTop::Socket.observe_method( :CURVE_client! )
		CZTop::Socket.observe_method( :connect )
		CZTop::Socket.observe_method( :disconnect )
		CZTop::Socket.observe_method( :close )
		CZTop::Socket.observe_method( :bind )
		CZTop::Socket.observe_method( :unbind )
		CZTop::Socket.observe_method( :signal )
		CZTop::Socket.observe_method( :wait )
	end


	when_installed( 'CZTop::Message' ) do
		CZTop::Message.extend( Observability )
		CZTop::Message.observe_class_method( :receive_from )
		CZTop::Message.observe_method( :send_to )
		CZTop::Message.observe_method( :<< )
		CZTop::Message.observe_method( :routing_id= )
	end

end # module Observability::Instrumentation::CZTop

