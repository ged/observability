#!/usr/bin/env ruby

# Can you prepend a module to a Class's singleton class to transparently override class methods?


class Foo

	def self::do_a_thing
		puts "I'm doing it!!"
	end

end


module Lazy

	def do_a_thing
		puts "Awww someone else will do it."
	end

end


Foo.singleton_class.prepend( Lazy )
Foo.do_a_thing


