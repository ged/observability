# -*- ruby -*-
# frozen_string_literal: true

require 'socket'
require 'pluggability'
require 'loggability'


require 'observability' unless defined?( Observability )


class Observability::Collector
	extend Loggability,
		Pluggability,
		Configurability

	# Loggability API -- log to the Observability logger
	log_to :observability

	# Set the directories to search for concrete subclassse
	plugin_prefixes 'observability/collector'

	# Configurability -- declare config settings and defaults
	configurability( 'observability.collector' ) do

		setting :type, default: 'timescale'

	end


	# Prevent direct instantiation
	private_class_method :new


	### Let subclasses be inherited
	def self::inherited( subclass )
		super
		subclass.public_class_method( :new )
	end


	### Start a collector of the specified +type+, returning only when it shuts down.
	def self::start( type=self.class.type )
		instance = self.create( type )
		instance.start
	end


	### Start the collector.
	def start
		# No-op
	end

end # class Observability::Collector

