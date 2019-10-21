# -*- ruby -*-
# frozen_string_literal: true

require 'socket'
require 'configurability'

require 'observability/sender' unless defined?( Observability::Sender )


# A sender that sends events as JSON over UDP.
class Observability::Sender::UDP < Observability::Sender
	extend Configurability


	# Number of seconds to wait between retrying a blocked write
	RETRY_INTERVAL = 0.25

	# The pipeline to use for turning events into network data
	SERIALIZE_PIPELINE = :resolve.to_proc >> JSON.method(:generate)


	# Declare configurable settings
	configurability( 'observability.sender.udp' ) do

		##
		# The host to send events to
		setting :host, default: 'localhost'

		##
		# The port to send events to
		setting :port, default: Observability::DEFAULT_PORT

	end


	### Create a new UDP sender
	def initialize( * )
		@socket = UDPSocket.new
	end


	######
	public
	######

	##
	# The socket to send events over
	attr_reader :socket


	### Start sending queued events.
	def start
		self.socket.connect( self.class.host, self.class.port )

		super
	end


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
			bytes = self.socket.sendmsg_nonblock( data, 0, exception: false )

			if bytes == :wait_writable
				IO.select( nil, [self.socket], nil )
			else
				self.log.debug "Sent: %p" % [ data[0, bytes] ]
				data[ 0, bytes ] = ''
			end
		end
	end

end # class Observability::Sender::UDP

