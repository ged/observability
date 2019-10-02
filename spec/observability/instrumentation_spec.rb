#!/usr/bin/env rspec -cfd

require_relative '../spec_helper'

require 'observability/instrumentation'


describe Observability::Instrumentation do

	let( :instrumentation ) do
		mod = Module.new
		mod.extend( described_class )
		return mod
	end


	it "provides a way to load instrumentation for common libraries" do
		expect( described_class ).to receive( :require ).
			with( 'observability/instrumentation/rack' )

		described_class.load( :rack )
	end


	it "can load several libraries at once" do
		expect( described_class ).to receive( :require ).
			with( 'observability/instrumentation/sequel' )
		expect( described_class ).to receive( :require ).
			with( 'observability/instrumentation/bunny' )

		described_class.load( :sequel, :bunny )
	end


	it "can install loaded instrumentation" do
		installation_callback_called = false

		instrumentation.when_installed do
			installation_callback_called = true
		end

		expect {
			described_class.install
		}.to change { installation_callback_called }.to( true )
	end

end

