# -*- ruby -*-
# frozen_string_literal: true

require 'simplecov' if ENV['COVERAGE']

require 'rspec'

require 'loggability/spechelpers'
require 'observability'


module Observability::SpecHelpers

	class TestingObserverAgent

		

	end


	### Temporarily replace event publishers with +new_publishers+ and register them.
	### Restore original publishers and any registrations after the given block returns.
	def self::replace_observers( new_observers=[] )
		original_observer = Observability.observer_agent

		Observability.observer_agent =

		begin
			yield()
		ensure
		end
	end


	### Hook the async publishing system on inclusion so events can be intercepted.
	def self::included( context )
		super

		context.around( :each ) do |example|
			if example.metadata[:observed]
				Cozy::AsyncJobs::SpecHelpers.replace_observers do
					example.run
				end
			else
				example.run
			end
		end
	end


	# Expectation class to match emitted events.
	class EventEmittedExpectation
		include RSpec::Matchers::Composable

		extend Loggability
		log_to :observability


		### Create a new expectation that an event will be emitted that matches the
		### given +criteria+.
		def initialize( *criteria )
			@critera = criteria
		end


		### RSpec matcher API -- specify that this matcher supports expect with a block.
		def supports_block_expectations?
			true
		end



	end # class EventEmittedExpectation


	### Expect an event matching the given +criteria+ to be emitted.
	def self::emit_event( *criteria )
		return EventEmittedExpectation.new( *criteria )
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


