#!/usr/bin/env rspec -cfd

require_relative '../spec_helper'

require 'observability/sender'
require 'observability/event'


describe Observability::Sender do

	it "is an abstract class" do
		expect {
			described_class.new
		}.to raise_error( NoMethodError, /private method `new'/i )
	end

end

