# -*- ruby -*-
# frozen_string_literal: true

require 'concurrent'
require 'loggability'

require 'observability' unless defined?( Observability )


class Observability::Observer
	extend Loggability


	# Pattern for finding places for underscores when changing a camel-cased string
	# to a snake-cased one.
	SNAKE_CASE_SEPARATOR = /(\P{Upper}\p{Upper}|\p{Lower}\P{Lower})/


	# Log to Observability's internal logger
	log_to :observability


	### Create a new Observer that will send events via the specified +sender+.
	def initialize( sender_type=nil )
		@sender = self.configured_sender( sender_type )
		@event_stack = Concurrent::ThreadLocalVar.new( &Array.method(:new) )
		@context_stack = Concurrent::ThreadLocalVar.new( &Array.method(:new) )
	end


	######
	public
	######

	##
	# The Observability::Sender used to deliver events
	attr_reader :sender


	### Start recording events and sending them.
	def start
		self.sender.start
	end


	### Stop recording and sending events.
	def stop
		self.sender.stop
	end


	### Create a new event with the specified +type+ and make it the current one.
	def event( type, **options, &block )
		type = self.type_from_object( type )
		fields = self.fields_from_options( options )

		parent = @event_stack.value.last
		event = Observability::Event.new( type, parent, **fields )
		@event_stack.value.push( event )

		new_context = @context_stack.value.last&.dup || {}
		@context_stack.value.push( new_context )

		return self.finish_after_block( event.object_id, &block ) if block
		return event.object_id
	end


	### Finish the and send the current event, comparing it against +event_marker+
	### and raising an exception if it's provided but doesn't match.
	### --
	### :TODO: Instead of raising, dequeue events up to the given marker if it
	###        exists in the queue?
	def finish( event_marker=nil )
		raise "Event mismatch" if
			event_marker && @event_stack.value.last.object_id != event_marker

		event = @event_stack.value.pop
		context = @context_stack.value.pop
		self.log.debug "Adding context %p (%d left) to finishing event." %
			[ context, @context_stack.value.length ]
		event.merge( context )

		self.log.debug "Finishing event: %p" % [ event ]
		self.sender.enqueue( event )

		return event
	end


	### Call the given +block+, then when it returns, finish the event that
	### corresponds to the given +marker+.
	def finish_after_block( event_marker=nil, &block )
		block.call( self )
	rescue Exception => err
		self.add( err )
		raise
	ensure
		self.finish( event_marker )
	end


	### Add an +object+ and/or a Hash of +fields+ to the current event.
	def add( object=nil, **fields )
		self.log.debug "Adding %p" % [ object || fields ]
		event = @event_stack.value.last or return

		if object
			object_fields = self.fields_from_object( object )
			fields = fields.merge( object_fields )
		end

		event.merge( fields )
	end


	### Add the specified +fields+ to the current event and any that are created
	### before the current event is finished.
	def add_context( object=nil, **fields )
		self.log.debug "Adding context from %p" % [ object || fields ]
		current_context = @context_stack.value.last or return

		if object
			object_fields = self.fields_from_object( object )
			fields = fields.merge( object_fields )
		end

		current_context.merge!( fields )
	end


	### Return the depth of the stack of pending events.
	def pending_event_count
		return @event_stack.value.length
	end


	### Returns +true+ if the Observer has events that are under construction.
	def has_pending_events?
		return self.pending_event_count.nonzero? ? true : false
	end
	alias_method :pending_events?, :has_pending_events?


	#########
	protected
	#########

	#
	# Types
	#

	### Derive an event type from the specified +object+ and an optional +block+
	### that provides additional context.
	def type_from_object( object, block=nil )
		case object
		when Module
			self.log.debug "Deriving a type from module %p" % [ object ]
			return self.type_from_module( object )

		when Method, UnboundMethod
			self.log.debug "Deriving a type from method %p" % [ object ]
			return self.type_from_method( object )

		when Array
			self.log.debug "Deriving a type from context %p" % [ object ]
			return self.type_from_context( *object )

		when Proc
			self.log.debug "Deriving a type from context proc %p" % [ object ]
			return self.type_from_context_proc( object )

		when String
			self.log.debug "Using string %p as type" % [ object ]
			return object

		else
			raise "don't know how to derive an event type from a %p" % [ object.class ]
		end
	end


	### Derive an event type from the specified Class or Module +object+.
	def type_from_module( object )
		if ( name = object.name )
			name = name.split( '::' ).collect do |part|
				part.gsub( SNAKE_CASE_SEPARATOR ) do |m|
					"%s_%s" % [ m[0], m[1] ]
				end
			end.join( '.' )

			return name.downcase
		else
			return "anonymous_%s_%d" % [ object.class.name.downcase, object.object_id ]
		end
	end


	### Derive an event type from the specified Method or UnboundMethod +object+.
	def type_from_method( object )
		name = object.original_name
		mod = object.owner

		return [ self.type_from_module(mod), name.to_s ].join( '.' )
	end


	### Derive an event type from the specified Method and a +detail+.
	def type_from_context( context, *details )
		prefix = self.type_from_object( context )
		suffix = details.map {|detail| detail.to_s }

		return ([prefix] + suffix).join( '.' )
	end


	### Derive an event type from the specified Proc, which should be a block passed
	### to an observed method.
	def type_from_context_proc( object )
		bind = object.binding
		recv = bind.receiver
		methname = bind.eval( "__method__" )
		meth = recv.method( methname )

		return self.type_from_object( meth )
	end


	#
	# Fields
	#

	### Extract fields specified by the specified +options+ and return them all
	### merged into one Hash.
	### :TODO: Handle options like :model, :timed, etc.
	def fields_from_options( options )
		fields = {}

		options.each do |key, value|
			self.log.debug "Applying option %p: %p" % [ key, value ]
			case key
			when :add
				fields.merge!( value )
			when :timed
				duration_callback = lambda {|ev| Concurrent.monotonic_time - ev.start }
				fields.merge!( duration: duration_callback )
			else
				raise "unknown event option %p" % [ key ]
			end
		end

		return fields
	end


	### Return a Hash of fields to add to the current event derived from the given
	### +object+.
	def fields_from_object( object )
		case object
		when ::Exception
			return self.fields_from_exception( object )
		else
			if object.respond_to?( :to_h )
				return object.to_h
			else
				raise "don't know how to derive fields from a %p" % [ object.class ]
			end
		end
	end


	### Return a Hash of fields to add to the current event derived from the given
	### +exception+ object.
	def fields_from_exception( exception )
		fields = {
			type: exception.class.name,
			message: exception.message,
		}

		if exception.cause
			cause_fields = self.fields_from_exception( exception.cause )
			fields[ :cause ] = cause_fields[ :error ]
		end

		if ( locations = exception.backtrace_locations )
			fields[ :backtrace ] = locations.map do |loc|
				{ label: loc.label, path: loc.absolute_path, lineno: loc.lineno }
			end
		end

		return { error: fields }
	end


	### Create an instance of the given +sender_type+, or the type specified in the
	### configuration if +sender_type+ is nil.
	def configured_sender( sender_type )
		return Observability::Sender.create( sender_type ) if sender_type
		return Observability::Sender.configured_type
	end

end # class Observability::Observer

