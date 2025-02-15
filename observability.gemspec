# -*- encoding: utf-8 -*-
# stub: observability 0.5.0.pre.20250214160829 ruby lib

Gem::Specification.new do |s|
  s.name = "observability".freeze
  s.version = "0.5.0.pre.20250214160829".freeze

  s.required_rubygems_version = Gem::Requirement.new(">= 0".freeze) if s.respond_to? :required_rubygems_version=
  s.metadata = { "bug_tracker_uri" => "https://todo.sr.ht/~ged/Observability/browse", "changelog_uri" => "http://deveiate.org/code/observability/History_md.html", "documentation_uri" => "http://deveiate.org/code/observability", "homepage_uri" => "https://hg.sr.ht/~ged/Observability", "source_uri" => "https://hg.sr.ht/~ged/Observability/browse" } if s.respond_to? :metadata=
  s.require_paths = ["lib".freeze]
  s.authors = ["Michael Granger".freeze]
  s.date = "2025-02-14"
  s.description = "Observability is a toolkit for instrumenting code to make it more observable. It follows the principle of Observability-Oriented Design as expressed by Charity Majors (@mipsytipsy).".freeze
  s.email = ["ged@faeriemud.org".freeze]
  s.executables = ["observability-collector".freeze]
  s.files = ["DevNotes.md".freeze, "History.md".freeze, "LICENSE.txt".freeze, "README.md".freeze, "bin/observability-collector".freeze, "lib/observability.rb".freeze, "lib/observability/collector.rb".freeze, "lib/observability/collector/rabbitmq.rb".freeze, "lib/observability/collector/timescale.rb".freeze, "lib/observability/event.rb".freeze, "lib/observability/instrumentation.rb".freeze, "lib/observability/instrumentation/bunny.rb".freeze, "lib/observability/instrumentation/cztop.rb".freeze, "lib/observability/instrumentation/grape.rb".freeze, "lib/observability/instrumentation/pg.rb".freeze, "lib/observability/instrumentation/rack.rb".freeze, "lib/observability/instrumentation/sequel.rb".freeze, "lib/observability/observer.rb".freeze, "lib/observability/observer_hooks.rb".freeze, "lib/observability/sender.rb".freeze, "lib/observability/sender/logger.rb".freeze, "lib/observability/sender/null.rb".freeze, "lib/observability/sender/testing.rb".freeze, "lib/observability/sender/udp.rb".freeze, "lib/observability/sender/udp_multicast.rb".freeze, "spec/observability/event_spec.rb".freeze, "spec/observability/instrumentation_spec.rb".freeze, "spec/observability/observer_hooks_spec.rb".freeze, "spec/observability/observer_spec.rb".freeze, "spec/observability/sender/logger_spec.rb".freeze, "spec/observability/sender/udp_spec.rb".freeze, "spec/observability/sender_spec.rb".freeze, "spec/observability_spec.rb".freeze, "spec/spec_helper.rb".freeze]
  s.homepage = "https://hg.sr.ht/~ged/Observability".freeze
  s.licenses = ["BSD-3-Clause".freeze]
  s.rubygems_version = "3.6.2".freeze
  s.summary = "Observability is a toolkit for instrumenting code to make it more observable.".freeze

  s.specification_version = 4

  s.add_runtime_dependency(%q<concurrent-ruby>.freeze, ["~> 1.1".freeze])
  s.add_runtime_dependency(%q<concurrent-ruby-ext>.freeze, ["~> 1.1".freeze])
  s.add_runtime_dependency(%q<loggability>.freeze, ["~> 0.15".freeze])
  s.add_runtime_dependency(%q<configurability>.freeze, ["~> 5.0".freeze])
  s.add_runtime_dependency(%q<pluggability>.freeze, ["~> 0.7".freeze])
  s.add_runtime_dependency(%q<msgpack>.freeze, ["~> 1.3".freeze])
  s.add_runtime_dependency(%q<uuid>.freeze, ["~> 2.3".freeze])
  s.add_development_dependency(%q<pg>.freeze, ["~> 1.1".freeze])
  s.add_development_dependency(%q<sequel>.freeze, ["~> 5.26".freeze])
  s.add_development_dependency(%q<timecop>.freeze, ["~> 0.9".freeze])
  s.add_development_dependency(%q<rake-deveiate>.freeze, ["~> 0.10".freeze])
  s.add_development_dependency(%q<simplecov>.freeze, ["~> 0.7".freeze])
  s.add_development_dependency(%q<rdoc-generator-sixfish>.freeze, ["~> 0.2".freeze])
end
