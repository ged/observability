#!/usr/bin/env rspec -cfd

require_relative '../spec_helper'

require 'observability/sender'
require 'observability/sender/testing'
require 'observability/event'


describe Observability::Sender do

	after( :all ) do
		described_class.configure
	end

	before( :each ) do
		described_class.configure
	end


	it "is an abstract class" do
		expect {
			described_class.new
		}.to raise_error( NoMethodError, /private method .new./i )
	end


	it "can create an instance of the configured type of sender" do
		described_class.configure( type: :testing )
		expect( described_class.configured_type ).to be_a( Observability::Sender::Testing )
	end


	context "concrete subclasses" do

		let( :subclass ) do
			Class.new( described_class ) do
				def initialize( * )
					super
					@sent = []
				end
				attr_reader :sent
				def send_event( ev )
					@sent << ev
				end
			end
		end

		let( :instance ) do
			subclass.new
		end


		it "sends events after it's started" do
			events = 12.times.map { Observability::Event.new('acme.windowwasher.refill') }

			instance.start
			instance.enqueue( *events ).wait( 0.5 )
			instance.stop

			expect( instance.sent ).to contain_exactly( *(events.map(&:resolve)) )
		end


		it "drops events if it hasn't been started yet" do
			events = 8.times.map { Observability::Event.new('acme.windowwasher.refill') }

			instance.enqueue( *events ).wait( 0.5 )

			expect( instance.sent ).to be_empty
		end


	end

end

