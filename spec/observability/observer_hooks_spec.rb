#!/usr/bin/env rspec -cfd

require_relative '../spec_helper'

require 'observability/observer_hooks'


describe Observability::ObserverHooks do

	let( :hooks_mod ) { described_class.dup }

	let( :observed_class ) do
		new_class = Class.new do
			def do_a_thing
				self.observe( :thing_done ) do
					self.do_it
				end
			end

			def do_it
				return :it_is_done
			end
		end
		new_class.prepend( hooks_mod )

		return new_class
	end
	let ( :expected_event_prefix ) { "anonymous_class_%d" % [ observed_class.object_id ] }


	it "provides an #observe instance method for generating events" do
		instance = observed_class.new

		expect {
			instance.do_a_thing
		}.to emit_event( "#{expected_event_prefix}.do_a_thing.thing_done" )
	end


	it "provides an instance method alias to the current Observability observer" do
		instance = observed_class.new

		expect( instance.observability ).to be( Observability.observer )
	end

end

