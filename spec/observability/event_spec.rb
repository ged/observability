#!/usr/bin/env rspec -cfd

require_relative '../spec_helper'

require 'observability/event'


describe Observability::Event do

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


	it 

end

