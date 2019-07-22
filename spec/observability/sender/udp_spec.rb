#!/usr/bin/env rspec -cfd

require_relative '../../spec_helper'

require 'observability/sender/udp'


describe Observability::Sender::UDP do

	before( :all ) do
		described_class.configure( host: 'localhost', port: 8787 )
	end

	after( :all ) do
		described_class.configure
	end


	let( :udp_socket ) { instance_double(UDPSocket) }
	let( :executor ) do
		instance_double( Concurrent::SingleThreadExecutor, :auto_terminate= => nil )
	end

	before( :each ) do
		allow( UDPSocket ).to receive( :new ).and_return( udp_socket )
		allow( Concurrent::SingleThreadExecutor ).to receive( :new ).and_return( executor )
	end


	it "sends events via a UDP socket" do
		event = Observability::Event.new( 'acme.engine.startup' )

		expect( executor ).to receive( :post ) do |*args, &block|
			block.call( *args )
		end
		expect( udp_socket ).to receive( :connect ).with( 'localhost', 8787 )
		expect( udp_socket ).to receive( :sendmsg_nonblock ) do |msg, flags, **opts|
			expect( msg ).to match( /\{.*"@type":"acme\.engine\.startup".*\}/ )
			expect( flags ).to eq( 0 )
			expect( opts ).to include( exception: false )
			msg.bytesize
		end

		sender = described_class.new
		sender.start
		sender.enqueue( event )
	end


	it "retries if writing would block" do
		event = Observability::Event.new( 'acme.engine.startup' )
		blocked_once = false

		expect( executor ).to receive( :post ) do |*args, &block|
			block.call( *args )
		end
		expect( udp_socket ).to receive( :connect ).with( 'localhost', 8787 )
		expect( udp_socket ).to receive( :sendmsg_nonblock ) do |msg, flags, **opts|
			if !blocked_once
				blocked_once = true
				:wait_writable
			elsif msg.bytesize > 5
				5
			else
				msg.bytesize
			end
		end.at_least( 2 ).times
		expect( IO ).to receive( :select ).with( nil, [udp_socket], nil ).
			and_return( nil, [udp_socket], nil ).
			once

		sender = described_class.new
		sender.start
		sender.enqueue( event )
	end


	it "shuts down the socket when it stops" do
		expect( udp_socket ).to receive( :shutdown ).with( :WR )

		sender = described_class.new
		sender.stop
	end

end

