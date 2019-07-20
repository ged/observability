# -*- ruby -*-
# frozen_string_literal: true

require_relative 'spec_helper'

require 'rspec'
require 'observability'
require 'observability/observer'


describe Observability do

	before( :all ) do
		@real_hook_mods = Observability.observer_hooks
		Observability.instance_variable_set( :@observer_hooks, Concurrent::Map.new )
	end

	before( :each ) do
		Observability.reset
		Observability.observer_hooks.keys.each {|key| Observability.observer_hooks.delete(key) }
	end

	after( :all ) do
		Observability.instance_variable_set( :@observer_hooks, @real_hook_mods )
	end


	it "can create a singleton observer" do
		result = described_class.observer
		expect( result ).to be_a( Observability::Observer )
	end


	it "doesn't race to create the singleton observer" do
		val1 = Thread.new { described_class.observer }.value
		val2 = Thread.new { described_class.observer }.value

		expect( val1 ).to be( val2 )
	end


	it "tracks the hook modules of all extended modules" do
		new_mod = Module.new
		new_mod.extend( described_class )
		expect( described_class.observer_hooks.keys ).to include( new_mod )
		expect( described_class.observer_hooks[new_mod] ).to be_a( Module )
	end


	it "tracks the hook modules of the singleton classes of all extended modules" do
		new_mod = Module.new
		new_mod.extend( described_class )
		s_class = new_mod.singleton_class
		expect( described_class.observer_hooks.keys ).to include( s_class )
		expect( described_class.observer_hooks[s_class] ).to be_a( Module )
	end


	describe "an including class" do

		let( :observed_class ) do
			the_class = Class.new do

				@class_things_done = 0
				def self::do_a_class_thing
					@class_things_done += 1
				end

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


		it "can decorate instance methods with observation" do
			observed_class.observe_method( :do_a_thing )
			object = observed_class.new

			expect {
				object.do_a_thing
			}.to emit_event( "anonymous_class_#{observed_class.object_id}.do_a_thing" )
		end


		it "can decorate class methods with observation" do
			observed_class.observe_class_method( :do_a_class_thing )

			expect {
				observed_class.do_a_class_thing
			}.to emit_event( "anonymous_class_#{observed_class.object_id}.do_a_class_thing" )
		end

	end

end

