#!/usr/bin/env ruby

# Experiment to see if you can make a prepended method without messing up the
# signature of the real method. I.e., can you super with * and maintain the same
# signature?


class A

	def something( foo:, bar: false )
		puts "Block given" if block_given?
		p [ foo, bar ]
	end

end

module Pre

	def something( * )
		puts "In Pre#something"
		super if defined?( super )
		puts "After A#something"
	end

end


A.prepend( Pre )

puts '--'
A.new.something( foo: 4, bar: :california ) { "and a block" }
puts '--'
A.new.something( bar: true, foo: 3 )
puts '--'
A.new.something( foo: 2 )
puts '--'
A.new.something
puts '--'

