#!/usr/bin/env rspec -cfd

require_relative '../../spec_helper'

require 'observability/sender/logger'
require 'observability/event'


describe Observability::Sender::Logger do

	it "sends events to its own logger" do
		sender = described_class.new
		sender.start

		event = Observability::Event.new( 'acme.engine.start' )

		log = []
		Loggability.outputting_to( log ).formatted_with( :default ).with_level( :debug ) do
			sender.enqueue( event )
		end
		sender.stop

		# Race to find the log
		expect( log ).to include( a_string_matching(/acme\.engine\.start/) )
	end

end

