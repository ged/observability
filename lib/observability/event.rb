# -*- ruby -*-
# frozen_string_literal: true

require 'time'
require 'forwardable'
require 'uuid'
require 'loggability'
require 'concurrent'

require 'observability' unless defined?( Observability )


class Observability::Event
	extend Loggability,
		Forwardable


	# The event format version to send with all events
	FORMAT_VERSION = 1


	# Loggability API -- send logs to the top-level module's logger
	log_to :observability


	### Return a generator that can return a unique ID string for identifying Events
	### across application boundaries.
	def self::id_generator
		return @id_generator ||= UUID.new
	end


	### Generate a new Event ID.
	def self::generate_id
		return self.id_generator.generate
	end


	### Create a new event
	def initialize( type, parent=nil, **fields )
		@id        = self.class.generate_id
		@parent_id = parent&.id
		@type      = type.freeze
		@timestamp = Time.now
		@start     = Concurrent.monotonic_time
		@fields    = fields
	end


	######
	public
	######

	##
	# The ID of the event, used to pass context through application boundaries
	attr_reader :id

	##
	# The ID of the containing context event, if there is one
	attr_reader :parent_id

	##
	# The type of the event, which should be a string of the form: 'foo.bar.baz'
	attr_reader :type

	##
	# The Time the event was created
	attr_reader :timestamp

	##
	# The monotonic clock time of when the event was created
	attr_reader :start

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
			data = self.fields.merge(
				:@id => self.id,
				:@parent_id => self.parent_id,
				:@type => self.type,
				:@timestamp => self.timestamp,
				:@version => FORMAT_VERSION
			)
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
			return value.iso8601( 6 )

		else
			return value
		end
	end

end # class Observability::Event

