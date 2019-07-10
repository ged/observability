# -*- ruby -*-
# frozen_string_literal: true

require_relative 'spec_helper'

require 'rspec'
require 'observability'
require 'observability/observer'


describe Observability do

	it "can create a singleton observer" do
		result = described_class.observer
		expect( result ).to be_a( Observability::Observer )
	end


	describe "an including class" do

		let( :observed_class ) do
			the_class = Class.new do

				def initialize
					@things_done = 0
				end

				attr_accessor :things_done

				def do_a_thing
					self.things_done += 1
				end
			end

			the_class.extend( described_class )
			return the_class
		end


		it "can decorate its instance methods with observation events" do
			observed_class.observe( :do_a_thing )

			expect {
				observed_class.new.do_a_thing
			}.to emit_event( 'spec.observed_class.do_a_thing' )
		end

	end

end

