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
		observer = described_class.new

		expect( observer ).to be_a( described_class )
		expect( observer.sender ).to be_a( Observability::Sender )
	end


	it "can create a new event" do
		marker = nil
		observer = described_class.new

		expect {
			marker = observer.event( 'acme.daemon.start' )
		}.to change { observer.pending_event_count }.by( 1 )

		expect( marker ).to be_an( Integer )
	end


	it "sends an event when it is finished" do
		observer = described_class.new( :testing )
		observer.event( 'acme.engine.throttle' )

		expect {
			observer.finish
		}.to change { observer.sender.enqueued_events.length }.by( 1 )

		event = observer.sender.enqueued_events.last
		expect( event.type ).to eq( 'acme.engine.throttle' )
	end


	it "sends an event when it is finished with the correct marker" do
		observer = described_class.new( :testing )
		marker = observer.event( 'acme.startup' )

		expect {
			observer.finish( marker )
		}.to change { observer.sender.enqueued_events.length }.by( 1 )
	end


	# :TODO: Should this behavior instead finish all events up to the specified marker instead?
	it "raises when finished with the incorrect marker" do
		observer = described_class.new( :testing )
		first_marker = observer.event( 'acme.startup' )
		second_marker = observer.event( 'acme.loop' )

		expect {
			observer.finish( first_marker )
		}.to raise_error( /event mismatch/i )
	end


	it "creates and event and finishes it immediately when passed a block" do
		observer = described_class.new( :testing )

		expect {
			observer.event( 'acme.gate' ) do |obs|
				obs.add( state: 'open' )
			end
		}.to change { observer.sender.enqueued_events.length }.by( 1 )

		event =  observer.sender.enqueued_events.last
		expect( event.type ).to eq( 'acme.gate' )
		expect( event.fields ).to eq( state: 'open' )
	end


	describe "event types" do

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

			expect( event.type ).to eq( "anonymous_module_#{mod.object_id}" )
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

			expect( event.type ).to eq( "anonymous_class_#{mod.object_id}" )
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


	describe "event options" do

		it "allows additions to be made to new events directly" do
			observer = described_class.new( :testing )
			observer.event( 'acme.engine.throttle', add: { factor: 7 } )
			event = observer.finish

			expect( event.resolve ).to include( factor: 7 )
		end


		describe ":model" do

			it "adds fields germane to processes for the process model"
			it "adds fields germane to threads for the thread model"
			it "adds fields germane to loops for the loop model"

		end


		describe ":timed" do

			it "adds a calculated duration field" do
				observer = described_class.new( :testing )
				observer.event( 'acme.engine.run', timed: true )
				sleep 0.1
				event = observer.finish

				expect( event.resolve ).to include( duration: a_value > 0.1 )
			end

		end

	end


	describe "derived fields" do

		it "can be added via an Exception" do
			observer = described_class.new( :testing )
			observer.event( 'acme.engine.start' )

			expect {
				observer.finish_after_block do
					raise "misfire!"
				end
			}.to raise_error( RuntimeError, 'misfire!' )

			event = observer.sender.enqueued_events.last
			expect( event.type ).to eq( 'acme.engine.start' )

			expect( event.fields ).to include(
				error: a_hash_including(
					type: 'RuntimeError',
					message: 'misfire!',
					backtrace: an_instance_of( Array )
				)
			)
			expect( event.resolve[:error][:backtrace] ).
				to all( be_a(Hash).and( include(:label, :path, :lineno) ) )
		end


		it "can be added for a secondary Exception" do
			observer = described_class.new( :testing )
			observer.event( 'acme.engine.start' )

			expect {
				observer.finish_after_block do
					begin
						raise "misfire!"
					rescue => err
						raise ArgumentError, "Cleared a misfire."
					end
				end
			}.to raise_error( ArgumentError, 'Cleared a misfire.' )

			event = observer.sender.enqueued_events.last
			expect( event.type ).to eq( 'acme.engine.start' )

			expect( event.fields ).to include(
				error: a_hash_including(
					type: 'ArgumentError',
					message: 'Cleared a misfire.',
					cause: a_hash_including(
						type: 'RuntimeError',
						message: 'misfire!',
						backtrace: an_instance_of( Array )
					)
				)
			)
		end


		it "can be added for any object that responds to #to_h" do
			observer = described_class.new( :testing )
			observer.event( 'acme.engine.start' )

			to_h_class = Class.new do
				def to_h
					return { sku: '121212', rev: '8c' }
				end
			end

			observer.add( to_h_class.new )
			event = observer.finish

			expect( event.resolve ).to include( sku: '121212', rev: '8c' )
		end

	end


	describe "context" do

		it "can be added for all inner events" do
			observer = described_class.new( :testing )
			event = observer.event( 'acme.engine.start' ) do
				observer.add_context( request_id: 'E30E90E0-585B-4015-9C96-AE6EC487970C' )

				inner_event = observer.event( 'acme.engine.rev' ) {}
			end

			expect( observer.sender.enqueued_events.map(&:resolve) ).
				to all( include( request_id: 'E30E90E0-585B-4015-9C96-AE6EC487970C' ) )
		end

	end

end

