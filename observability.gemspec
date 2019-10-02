# -*- encoding: utf-8 -*-
# stub: observability 0.2.0.pre.20191001194449 ruby lib

Gem::Specification.new do |s|
  s.name = "observability".freeze
  s.version = "0.2.0.pre.20191001194449"

  s.required_rubygems_version = Gem::Requirement.new("> 1.3.1".freeze) if s.respond_to? :required_rubygems_version=
  s.require_paths = ["lib".freeze]
  s.authors = ["Michael Granger".freeze]
  s.date = "2019-10-01"
  s.description = "Observability is a toolkit for instrumenting code to make it more observable.\nIt follows the principle of Observability-Oriented Design as expressed by Charity\nMajors (@mipsytipsy).".freeze
  s.email = ["ged@faeriemud.org".freeze]
  s.files = [".document".freeze, ".rdoc_options".freeze, ".simplecov".freeze, "ChangeLog".freeze, "DevNotes.md".freeze, "History.md".freeze, "LICENSE.txt".freeze, "Manifest.txt".freeze, "README.md".freeze, "Rakefile".freeze, "bin/observability-collector".freeze, "examples/basic-usage.rb".freeze, "lib/observability.rb".freeze, "lib/observability/collector.rb".freeze, "lib/observability/collector/timescale.rb".freeze, "lib/observability/event.rb".freeze, "lib/observability/observer.rb".freeze, "lib/observability/observer_hooks.rb".freeze, "lib/observability/sender.rb".freeze, "lib/observability/sender/logger.rb".freeze, "lib/observability/sender/null.rb".freeze, "lib/observability/sender/testing.rb".freeze, "lib/observability/sender/udp.rb".freeze, "spec/observability/event_spec.rb".freeze, "spec/observability/observer_hooks_spec.rb".freeze, "spec/observability/observer_spec.rb".freeze, "spec/observability/sender/logger_spec.rb".freeze, "spec/observability/sender/udp_spec.rb".freeze, "spec/observability/sender_spec.rb".freeze, "spec/observability_spec.rb".freeze, "spec/spec_helper.rb".freeze]
  s.licenses = ["BSD-3-Clause".freeze]
  s.rubygems_version = "3.0.3".freeze
  s.summary = "Observability is a toolkit for instrumenting code to make it more observable.".freeze

  if s.respond_to? :specification_version then
    s.specification_version = 4

    if Gem::Version.new(Gem::VERSION) >= Gem::Version.new('1.2.0') then
      s.add_runtime_dependency(%q<concurrent-ruby>.freeze, ["~> 1.1.5"])
      s.add_runtime_dependency(%q<concurrent-ruby-ext>.freeze, ["~> 1.1.5"])
      s.add_runtime_dependency(%q<loggability>.freeze, ["~> 0.11"])
      s.add_runtime_dependency(%q<configurability>.freeze, ["~> 3.3"])
      s.add_runtime_dependency(%q<pluggability>.freeze, ["~> 0.6"])
      s.add_runtime_dependency(%q<msgpack>.freeze, ["~> 1.3"])
      s.add_development_dependency(%q<timecop>.freeze, ["~> 0.9"])
      s.add_development_dependency(%q<rake-deveiate>.freeze, ["~> 0.1"])
      s.add_development_dependency(%q<simplecov>.freeze, ["~> 0.7"])
      s.add_development_dependency(%q<rdoc-generator-fivefish>.freeze, ["~> 0.1"])
    else
      s.add_dependency(%q<concurrent-ruby>.freeze, ["~> 1.1.5"])
      s.add_dependency(%q<concurrent-ruby-ext>.freeze, ["~> 1.1.5"])
      s.add_dependency(%q<loggability>.freeze, ["~> 0.11"])
      s.add_dependency(%q<configurability>.freeze, ["~> 3.3"])
      s.add_dependency(%q<pluggability>.freeze, ["~> 0.6"])
      s.add_dependency(%q<msgpack>.freeze, ["~> 1.3"])
      s.add_dependency(%q<timecop>.freeze, ["~> 0.9"])
      s.add_dependency(%q<rake-deveiate>.freeze, ["~> 0.1"])
      s.add_dependency(%q<simplecov>.freeze, ["~> 0.7"])
      s.add_dependency(%q<rdoc-generator-fivefish>.freeze, ["~> 0.1"])
    end
  else
    s.add_dependency(%q<concurrent-ruby>.freeze, ["~> 1.1.5"])
    s.add_dependency(%q<concurrent-ruby-ext>.freeze, ["~> 1.1.5"])
    s.add_dependency(%q<loggability>.freeze, ["~> 0.11"])
    s.add_dependency(%q<configurability>.freeze, ["~> 3.3"])
    s.add_dependency(%q<pluggability>.freeze, ["~> 0.6"])
    s.add_dependency(%q<msgpack>.freeze, ["~> 1.3"])
    s.add_dependency(%q<timecop>.freeze, ["~> 0.9"])
    s.add_dependency(%q<rake-deveiate>.freeze, ["~> 0.1"])
    s.add_dependency(%q<simplecov>.freeze, ["~> 0.7"])
    s.add_dependency(%q<rdoc-generator-fivefish>.freeze, ["~> 0.1"])
  end
end
