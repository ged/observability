#!/usr/bin/env rspec -cfd

require_relative '../spec_helper'

require 'timecop'
require 'observability/event'


describe Observability::Event do

	before( :all ) do
		@real_tz = ENV['TZ']
		ENV['TZ'] = 'America/Los_Angeles'
	end

	after( :all ) do
		ENV['TZ'] = @real_tz
	end


	it "can be created with just a type" do
		event = described_class.new( 'acme.daemon.start' )

		expect( event ).to be_a( described_class )
		expect( event.type ).to eq( 'acme.daemon.start' )
	end


	it "can be created with a type and one or more fields" do
		event = described_class.new( 'acme.user.review', score: 100, time: 48 )

		expect( event ).to be_a( described_class )
		expect( event.type ).to eq( 'acme.user.review' )
		expect( event.fields ).to eq( score: 100, time: 48 )
	end


	it "returns a structured log entry when resolved" do
		event = described_class.new( 'acme.user.review', score: 100, time: 48 )
		expect( event.resolve ).to be_a( Hash ).and( include(score: 100, time: 48) )
	end


	it "prevents adding more fields after it's been resolved" do
		event = described_class.new( 'acme.user.review', score: 100, time: 48 )

		event.resolve

		expect {
			event.merge( foo: 1 )
		}.to raise_error( /already resolved/i )
	end


	it "adds its type to the resolved fields" do
		event = described_class.new( 'acme.user.review' )
		expect( event.resolve ).to include( :@type => event.type )
	end


	it "adds a timestamp to the resolved fields" do
		Timecop.freeze( Time.at(1563821278.609382) ) do
			expect( Time.now.to_f ).to eq( 1563821278.609382 )
			event = described_class.new( 'acme.user.review' )
			expect( event.resolve ).to include(
				:@timestamp => a_string_matching( /2019-07-22T11:47:58\.\d{6}-07:00/ )
			)
		end
	end


	it "has a monotonic timestamp of when it was created" do
		event = described_class.new( 'acme.daemon.start' )

		expect( event.start ).to be_a( Float ).and( be < Concurrent.monotonic_time )
	end


	it "freezes its type" do
		event = described_class.new( 'acme.daemon.start' )

		expect( event.type ).to be_frozen
	end


	it "can merge new field data" do
		event = described_class.new( 'acme.daemon.start', time: 1563379346 )

		expect {
			event.merge( end_time: 1563379417 )
		}.to change { event.fields }.to( time: 1563379346, end_time: 1563379417 )
	end


	it "calls fields which are callables when it is resolved" do
		event = described_class.new( 'acme.user.speed',
			start: Process.clock_gettime(Process::CLOCK_MONOTONIC),
			duration: ->(ev){ Process.clock_gettime(Process::CLOCK_MONOTONIC) - ev[:start] } )

		sleep 0.25

		expect( event.resolve[:duration] ).to be_a( Float ).and( be > 0.25 )
	end

end

