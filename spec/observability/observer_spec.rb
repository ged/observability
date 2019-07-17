#!/usr/bin/env rspec -cfd

require_relative '../spec_helper'

require 'observability/observer'


# A module and class for testing derived event types
module FooLibrary
	module Bar
		class BazAdapter
			def start; end
		end
	end
end


describe Observability::Observer do

	it "can be created with a default sender" do
		expect( subject ).to be_a( described_class )
		expect( subject.sender ).to be_a( Observability::Sender )
	end


	it "can create a new event" do
		marker = nil

		expect {
			marker = subject.event( 'acme.daemon.start', time: 1563379346 )
		}.to change { subject.pending_event_count }.by( 1 )

		expect( marker ).to be_an( Integer )
	end


	it "sends an event when it is finished" do
		observer = described_class.new( :testing )
		observer.event( 'acme.engine.throttle', start: 1563379417, revs: 13045 )

		expect {
			observer.finish
		}.to change { observer.sender.enqueued_events.length }.by( 1 )

		event = observer.sender.enqueued_events.last
		expect( event.type ).to eq( 'acme.engine.throttle' )
		expect( event.fields ).to eq( start: 1563379417, revs: 13045 )
	end


	it "sends an event when it is finished with the correct marker" do
		observer = described_class.new( :testing )
		marker = observer.event( 'acme.startup', count: 8 )

		expect {
			observer.finish( marker )
		}.to change { observer.sender.enqueued_events.length }.by( 1 )
	end


	# :TODO: Should this behavior instead finish all events up to the specified marker instead?
	it "raises when finished with the incorrect marker" do
		observer = described_class.new( :testing )
		first_marker = observer.event( 'acme.startup', time: 1563379417 )
		second_marker = observer.event( 'acme.loop', count: 8 )

		expect {
			observer.finish( first_marker )
		}.to raise_error( /event mismatch/i )
	end


	context "event types" do

		it "can be set directly by passing a String" do
			observer = described_class.new( :testing )
			observer.event( 'acme.factory.deploy' )

			event = observer.finish

			expect( event.type ).to eq( 'acme.factory.deploy' )
		end


		it "can be derived from a named Module" do
			observer = described_class.new( :testing )
			observer.event( FooLibrary::Bar )

			event = observer.finish

			expect( event.type ).to eq( 'foo_library.bar' )
		end


		it "can be derived from an anonymous Module" do
			mod = Module.new
			observer = described_class.new( :testing )
			observer.event( mod )

			event = observer.finish

			expect( event.type ).to eq( "anonymous_module.#{mod.object_id}" )
		end


		it "can be derived from a named Class" do
			observer = described_class.new( :testing )
			observer.event( FooLibrary::Bar::BazAdapter )

			event = observer.finish

			expect( event.type ).to eq( "foo_library.bar.baz_adapter" )
		end


		it "can be derived from an anonymous Class" do
			mod = Class.new
			observer = described_class.new( :testing )
			observer.event( mod )

			event = observer.finish

			expect( event.type ).to eq( "anonymous_class.#{mod.object_id}" )
		end


		it "can be derived from an UnboundMethod" do
			observer = described_class.new( :testing )
			observer.event( FooLibrary::Bar::BazAdapter.instance_method(:start) )

			event = observer.finish

			expect( event.type ).to eq( "foo_library.bar.baz_adapter.start" )
		end


		it "can be derived from a bound Method" do
			observer = described_class.new( :testing )
			observer.event( FooLibrary::Bar::BazAdapter.new.method(:start) )

			event = observer.finish

			expect( event.type ).to eq( "foo_library.bar.baz_adapter.start" )
		end


		it "can be derived from a Method and a Symbol" do
			obj = FooLibrary::Bar::BazAdapter.new
			meth = obj.method( :start )

			observer = described_class.new( :testing )
			observer.event( [meth, :loop] )

			event = observer.finish

			expect( event.type ).to eq( "foo_library.bar.baz_adapter.start.loop" )
		end


		it "can be derived from a Proc and a Symbol" do
			obj = FooLibrary::Bar::BazAdapter.new
			meth = obj.method( :start )

			observer = described_class.new( :testing )
			observer.event( [meth, :loop] )

			event = observer.finish

			expect( event.type ).to eq( "foo_library.bar.baz_adapter.start.loop" )
		end

	end

end

