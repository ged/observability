#!/usr/bin/env rspec -cfd

require_relative '../spec_helper'

require 'observability/observer'


describe Observability::Observer do

	it "can be created with a default sender" do
		expect( subject ).to be_a( described_class )
		expect( subject.sender ).to be_a( Observability::Sender )
	end


	it "can create a new event" do
		expect( subject. )
	end

end

