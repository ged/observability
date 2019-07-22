# -*- ruby -*-
# frozen_string_literal: true

require 'time'
require 'forwardable'
require 'loggability'

require 'observability' unless defined?( Observability )


class Observability::Event
	extend Loggability,
		Forwardable


	# Loggability API -- send logs to the top-level module's logger
	log_to :observability


	### Create a new event
	def initialize( type, **fields )
		@type      = type.freeze
		@timestamp = Time.now
		@fields    = fields
	end


	######
	public
	######

	##
	# The type of the event, which should be a string of the form: 'foo.bar.baz'
	attr_reader :type

	##
	# The Time the event was created
	attr_reader :timestamp

	##
	# A Symbol-keyed Hash of values that make up the event data
	attr_reader :fields

	##
	# Delegate some read-only methods to the #fields Hash.
	def_instance_delegators :fields, :[], :keys


	### Merge the specified +fields+ into the event's data.
	### :TODO: Handle conflicts?
	def merge( fields )
		self.fields.merge!( fields )
	rescue FrozenError => err
		raise "event is already resolved", cause: err
	end


	### Finalize all of the event's data and return it as a Hash.
	def resolve
		unless @fields.frozen?
			self.log.debug "Resolving event %#x" % [ self.object_id ]
			data = self.fields.merge( :@type => self.type, :@timestamp => self.timestamp )
			data = data.transform_values( &self.method(:resolve_value) )
			@fields = data.freeze
		end

		return @fields
	end
	alias_method :to_h, :resolve


	### Resolve the given +value+ into a serializable object.
	def resolve_value( value )
		case

		when value.respond_to?( :call ) # Procs, Methods
			return value.call( self )

		when value.respond_to?( :iso8601 ) # Time, Date, DateTime, etc.
			return value.iso8601

		else
			return value
		end
	end

end # class Observability::Event

