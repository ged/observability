#!/usr/bin/env ruby

# An experiment to see what happens when you call a block built in one thread from another one; is
# its closure visible from the second thread?


class BlockHolder

	def initialize
		@block = nil
	end

	def hold_block( &block )
		@block = block
	end

	def call_block
		raise "Block isn't set" unless @block
		@block.call if @block
	end

end


holder = Thread.new do
	bh = BlockHolder.new
	bh.hold_block { :foo }
	bh
end.value

Thread.new do
	puts holder.call_block
end.join




