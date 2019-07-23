# -*- ruby -*-
# frozen_string_literal: true

require 'json'
require 'concurrent'
require 'pluggability'

require 'observability' unless defined?( Observability )


class Observability::Sender
	extend Pluggability,
		Loggability,
		Configurability


	# Logs go to the main module
	log_to :observability

	# Set the prefix for derivative classes
	plugin_prefixes 'observability/sender'

	# Configuration settings
	configurability( 'observability.sender' ) do

		##
		# The sender type to use
		setting :type, default: :null

	end



	# Prevent direct instantiation
	private_class_method :new

	### Let subclasses be inherited
	def self::inherited( subclass )
		super
		subclass.public_class_method( :new )
	end


	### Return an instance of the configured type of Sender.
	def self::configured_type
		return self.create( self.type )
	end


	### Set up some instance variables
	def initialize # :notnew:
		@executor = nil
	end


	######
	public
	######

	##
	# The processing executor.
	attr_reader :executor


	### Start sending queued events.
	def start
		self.log.debug "Starting a %p" % [ self.class ]
		@executor = Concurrent::SingleThreadExecutor.new( fallback_policy: :abort )
		@executor.auto_terminate = true
	end


	### Stop the sender's executor.
	def stop
		self.log.debug "Stopping the %p" % [ self.class ]
		return if !self.executor || self.executor.shuttingdown? || self.executor.shutdown?

		self.log.debug "  shutting down the executor"
		self.executor.shutdown
		unless self.executor.wait_for_termination( 3 )
			self.log.debug "  killing the executor"
			self.executor.halt
			self.executor.wait_for_termination( 3 )
		end
	end


	### Queue up the specified +events+ for sending.
	def enqueue( *events )
		posted_event = Concurrent::Event.new

		unless self.executor
			self.log.debug "No executor; dropping %d events" % [ events.length ]
			posted_event.set
			return posted_event
		end

		self.executor.post( *events ) do |*ev|
			serialized = self.serialize_events( ev.flatten )
			serialized.each do |ev|
				self.send_event( ev )
			end
			posted_event.set
		end

		return posted_event
	end


	#########
	protected
	#########

	### Serialize each the given +events+ and return the results.
	def serialize_events( events )
		return events.map( &:resolve )
	end


	### Send the specified +event+.
	def send_event( event )
		self.log.warn "%p does not implement required method %s" % [ self.class, __method__ ]
	end

end # class Observability::Sender


