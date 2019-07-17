#!/usr/bin/env rspec -cfd

require_relative '../spec_helper'

require 'observability/observer_hooks'


describe Observability::ObserverHooks do

	let( :hooks_mod ) { described_class.dup }


	it "provides an #observe instance method for generating events" do
		observed_class = Class.new do
			def do_a_thing
				self.observe( :thing_done ) do
					self.do_it
				end
			end

			def do_it
				return :it_is_done
			end
		end

		observed_class.prepend( hooks_mod )
		instance = observed_class.new
		expected_event_prefix = "anonymous_class.%d" % [ observed_class.object_id ]

		expect {
			instance.do_a_thing
		}.to emit_event( "#{expected_event_prefix}.do_a_thing.thing_done" )
	end

end

