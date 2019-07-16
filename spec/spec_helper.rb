# -*- ruby -*-
# frozen_string_literal: true

require 'simplecov' if ENV['COVERAGE']

require 'rspec'

require 'loggability/spechelpers'
require 'observability'


module Observability::SpecHelpers

	### Replace the real observer with a new one with a sender of the given
	### +sender_type+, yield to the block, then restore the real observer.
	def self::replace_observer( sender_type )
		real_ivar = Observability.instance_variable_get( :@observer )

		new_sender = Observability::Sender.get_subclass( sender_type )
		new_observer = Observability::Observer.new( new_sender )
		new_ivar = Concurrent::IVar.new( new_observer )

		begin
			Observability.instance_variable_set( :@observer, new_ivar )
			yield( new_observer )
		ensure
			Observability.instance_variable_set( :@observer, real_ivar )
		end
	end



	class TestingSender < Observability::Sender

		def initialize( * )
			@enqueued_events = []
		end

		attr_reader :enqueued_events


		def start; end
		def stop; end


		def enqueue( *events )
			@enqueued_events.concat( events )
		end


		### (Undocumented)
		def event_was_sent?
			
		end

	end # class TestingSender


	# Expectation class to match emitted events.
	class EventEmittedExpectation
		include RSpec::Matchers::Composable

		extend Loggability
		log_to :observability


		### Create a new expectation that an event will be emitted that matches the
		### given +criteria+.
		def initialize( *criteria )
			@critera       = criteria
			@prelude_error = nil
			@sender        = nil
		end


		### RSpec matcher API -- specify that this matcher supports expect with a block.
		def supports_block_expectations?
			return true
		end


		### Return +true+ if the +given_proc+ is a valid callable.
		def valid_proc?( given_proc )
			return true if given_proc.respond_to?( :call )

			warn "`emit_event` was called with non-proc object #{given_proc.inspect}"
			return false
		end


		### Returns +true+ if the +given_proc+ results in an observation that matches
		### the built-up criteria to be sent.
		def matches?( given_proc )
			return false unless self.valid_proc?( given_proc )
			return self.run_with_test_sender( given_proc )
		end


		### RSpec negated matcher API -- return +true+ if an observation is not built when
		### the +given_proc+ is called.
		def does_not_match?( given_proc )
			return false unless self.valid_proc?( given_proc )
			self.run_with_test_sender( given_proc )

			return !( @prelude_error || self.job_ran_normally? )
		end


		### Run the +given_proc+ with async publication emulation set up.
		def run_with_test_sender( given_proc )
			Observability::SpecHelpers.replace_observer( :testing ) do |observer|
				@sender = observer.sender
				begin
					given_proc.call
				rescue => err
					@prelude_error = err
				end
			end

			return self.job_ran_normally?
		end


		### Returns +true+ if the job ran and succeeded.
		def job_ran_normally?
			return @sender.event_was sent? &&
				@sender.event_result &&
				!@sender.event_result.is_a?( ::Exception )
		end


		### Return a failure message based on the current state of the matcher.
		def failure_message
			return self.describe_prelude_error if @prelude_error
			return "no events were sent" unless @sender.event_was_sent?

			if @sender.event_result.is_a?( ::Exception )
				return "event failed permanently (%p: %s)\n%s" % [
					@sender.event_result.class,
					@sender.event_result.message,
					@sender.event_result.backtrace.join( "\n" )
				]
			end

			return "event was sent, but returned %p (retry)" % [ @sender.event_result ]
		end
		alias_method :failure_message_for_should, :failure_message


		### Return a failure message based on the current state of the matcher when it was
		### passed to a `to_not`.
		def failure_message_when_negated
			return self.describe_prelude_error if @prelude_error
			return "expected not to run the async event, but it did"
		end
		alias_method :failure_message_for_should_not, :failure_message_when_negated


		### Return a String describing an error which happened in the spec's
		### block before the event started.
		def describe_prelude_error
			return "%p before the event was sent: %s\n  " % [
				@prelude_error.class,
				@prelude_error.message,
				@prelude_error.backtrace.join( "\n  " )
			]
		end

	end # class EventEmittedExpectation


	### Expect an event matching the given +criteria+ to be emitted.
	def emit_event( *criteria )
		return Observability::SpecHelpers::EventEmittedExpectation.new( *criteria )
	end

end # module Observability::SpecHelpers


### Mock with RSpec
RSpec.configure do |config|
	config.run_all_when_everything_filtered = true
	config.filter_run :focus
	config.order = 'random'
	config.mock_with( :rspec ) do |mock|
		mock.syntax = :expect
	end

	config.include( Loggability::SpecHelpers )
	config.include( Observability::SpecHelpers )
end


