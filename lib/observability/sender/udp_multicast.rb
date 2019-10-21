# -*- ruby -*-
# frozen_string_literal: true

require 'socket'
require 'configurability'

require 'observability/sender' unless defined?( Observability::Sender )

# A sender that sends events as JSON over multicast UDP.
class Observability::Sender::UdpMulticast < Observability::Sender
	extend Configurability


	# Number of seconds to wait between retrying a blocked write
	RETRY_INTERVAL = 0.25

	# The pipeline to use for turning events into network data
	SERIALIZE_PIPELINE = :resolve.to_proc >> JSON.method( :generate )


	# Declare configurable settings
	configurability( 'observability.sender.udp' ) do

		##
		# The local address to bind to
		setting :bind_address, default: '0.0.0.0'

		##
		# The address of the multicast group to join
		setting :multicast_address, default: '224.15.7.75'

		##
		# The TTL of the outgoing messages, i.e., how many hops they will be limited to
		setting :multicast_ttl, default: 1

		##
		# The port to bind to
		setting :port, default: Observability::DEFAULT_PORT

	end


	### Return an IPAddr that represents the local + multicast addresses to bind to.
	def self::bind_addr
		return IPAddr.new( self.bind_address ).hton + IPAddr.new( self.multicast_address ).hton
	end


	### Create a new UDP sender
	def initialize( * )
		@multicast_address = self.class.multicast_address
		@port              = self.class.port
		@socket            = self.create_socket
	end


	######
	public
	######

	##
	# The address of the multicast group to send to
	attr_reader :multicast_address

	##
	# The port to send on
	attr_reader :port

	##
	# The socket to send events over
	attr_reader :socket


	### Stop the sender's executor.
	def stop
		super

		self.socket.shutdown( :WR )
	end


	### Serialize each the given +events+ and return the results.
	def serialize_events( events  )
		return events.map( &SERIALIZE_PIPELINE )
	end


	### Send the specified +event+.
	def send_event( data )

		until data.empty?
			bytes = self.socket.send( data, 0, self.multicast_address, self.port )

			self.log.debug "Sent: %p" % [ data[0, bytes] ]
			data[ 0, bytes ] = ''
		end
	end


	### Create and return a UDPSocket after setting it up for multicast.
	def create_socket
		iaddr = self.class.bind_addr
		socket = UDPSocket.new

		socket.setsockopt( :IPPROTO_IP, :IP_ADD_MEMBERSHIP, iaddr )
		socket.setsockopt( :IPPROTO_IP, :IP_MULTICAST_TTL, self.class.multicast_ttl )
		socket.setsockopt( :IPPROTO_IP, :IP_MULTICAST_LOOP, 1 )
		socket.setsockopt( :SOL_SOCKET, :SO_REUSEPORT, 1 )

		return socket
	end

end # class Observability::Sender::UDP

