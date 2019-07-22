# -*- ruby -*-
# frozen_string_literal: true

require 'loggability'

require 'observability' unless defined?( Observability )


class Observability::Event
	extend Loggability


	# Loggability API -- send logs to the top-level module's logger
	log_to :observability


	### Create a new event
	def initialize( type, **fields )
		@type   = type.freeze
		@fields = fields
	end


	######
	public
	######

	##
	# The type of the event, which should be a string of the form: 'foo.bar.baz'
	attr_reader :type

	##
	# A Symbol-keyed Hash of values that make up the event data
	attr_reader :fields


	### Merge the specified +fields+ into the event's data.
	### :TODO: Handle conflicts?
	def merge( fields )
		self.fields.merge!( fields )
	end


	### Finalize all of the event's data and return it as a Hash.
	def resolve
		return self.fields.merge( :@type => self.type )
	end
	alias_method :to_h, :resolve

end # class Observability::Event

