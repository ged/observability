# -*- ruby -*-
# frozen_string_literal: true

require 'concurrent'
require 'pluggability'

require 'observability' unless defined?( Observability )


class Observability::Sender
	extend Pluggability,
		Loggability


	# Logs go to the main module
	log_to :observability

	# Set the prefix for derivative classes
	plugin_prefixes 'observability/sender'



	# Prevent direct instantiation
	private_class_method :new

	### Let subclasses be inherited
	def self::inherited( subclass )
		super
		subclass.public_class_method( :new )
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
		@executor = Concurrent::SingleThreadExecutor.new
		@executor.auto_terminate = true
	end


	### Stop the sender's executor.
	def stop
		return if self.executor.shuttingdown? || self.executor.shutdown?

		self.executor.shutdown
		unless self.executor.wait_for_termination( 3 )
			self.executor.halt
			self.executor.wait_for_termination( 3 )
		end
	end


	### Queue up the specified +events+ for sending.
	def enqueue( *events )
		return unless self.executor.running?
		self.executor.post( *events ) do |*ev|
			ev.each {|ev| self.send_event(ev) }
		end
	end


	#########
	protected
	#########

	### Send the specified +event+.
	def send_event( event )
		raise NotImplementedError,
			"%p does not implement required method %s" % [ self.class, __method__ ]
	end

end # class Observability::Sender


