source 'https://rubygems.org'

gem 'concurrent-ruby', '~> 1.1'
gem 'concurrent-ruby-ext', '~> 1.1'
gem 'loggability', '~> 0.15'
gem 'configurability', '~> 4.0'
gem 'pluggability', '~> 0.7'
gem 'msgpack', '~> 1.3'
gem 'uuid', '~> 2.3'

group :development do
	gem 'pg', '~> 1.1'
	gem 'sequel', '~> 5.26'
	gem 'timecop', '~> 0.9'
	gem 'rake-deveiate', '~> 0.10'
	gem 'simplecov', '~> 0.7'
	gem 'rdoc-generator-fivefish', '~> 0.1'
end


