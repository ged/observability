# -*- encoding: utf-8 -*-
# stub: observability 0.1.0.pre20190722135324 ruby lib

Gem::Specification.new do |s|
  s.name = "observability".freeze
  s.version = "0.1.0.pre20190722135324"

  s.required_rubygems_version = Gem::Requirement.new("> 1.3.1".freeze) if s.respond_to? :required_rubygems_version=
  s.require_paths = ["lib".freeze]
  s.authors = ["Michael Granger".freeze]
  s.cert_chain = ["certs/ged.pem".freeze]
  s.date = "2019-07-22"
  s.description = "Observability is a toolkit for instrumenting code to make it more observable,\nfollowing the principle of Observability-Oriented Design as expressed by Charity\nMajors (@mipsytipsy).\n\nIts goals are [stolen from https://charity.wtf/2019/02/05/logs-vs-structured-events/]:\n\n* Emit a rich record from the perspective of a single action as the code is\n  executing.\n* Emit a single event per action per system that it occurs in. Write it out just\n  before the action completes or errors.\n* Bypass local disk entirely, write to a remote service.\n* Sample if needed for cost or resource constraints. Practice dynamic sampling.\n* Treat this like operational data, not transactional data. Be profligate and\n  disposable.\n* Feed this data into a columnar store or honeycomb or similar\n* Now use it every day. Not just as a last resort. Get knee deep in production\n  every single day. Explore. Ask and answer rich questions about your systems,\n  system quality, system behavior, outliers, error conditions, etc. You will be\n  absolutely amazed how useful it is \u2026 and appalled by what you turn up. \u{1F642}".freeze
  s.email = ["ged@FaerieMUD.org".freeze]
  s.executables = ["observability-collector".freeze]
  s.extra_rdoc_files = ["DevNotes.md".freeze, "History.md".freeze, "LICENSE.txt".freeze, "Manifest.txt".freeze, "README.md".freeze, "DevNotes.md".freeze, "History.md".freeze, "README.md".freeze]
  s.files = [".document".freeze, ".rdoc_options".freeze, ".simplecov".freeze, "ChangeLog".freeze, "DevNotes.md".freeze, "History.md".freeze, "LICENSE.txt".freeze, "Manifest.txt".freeze, "README.md".freeze, "Rakefile".freeze, "bin/observability-collector".freeze, "examples/basic-usage.rb".freeze, "lib/observability.rb".freeze, "lib/observability/collector.rb".freeze, "lib/observability/collector/timescale.rb".freeze, "lib/observability/event.rb".freeze, "lib/observability/observer.rb".freeze, "lib/observability/observer_hooks.rb".freeze, "lib/observability/sender.rb".freeze, "lib/observability/sender/logger.rb".freeze, "lib/observability/sender/null.rb".freeze, "lib/observability/sender/testing.rb".freeze, "lib/observability/sender/udp.rb".freeze, "spec/observability/event_spec.rb".freeze, "spec/observability/observer_hooks_spec.rb".freeze, "spec/observability/observer_spec.rb".freeze, "spec/observability/sender/logger_spec.rb".freeze, "spec/observability/sender/udp_spec.rb".freeze, "spec/observability/sender_spec.rb".freeze, "spec/observability_spec.rb".freeze, "spec/spec_helper.rb".freeze]
  s.homepage = "http://bitbucket.org/ged/observability".freeze
  s.licenses = ["BSD-3-Clause".freeze]
  s.rdoc_options = ["--main".freeze, "README.md".freeze]
  s.required_ruby_version = Gem::Requirement.new(">= 2.4.0".freeze)
  s.rubygems_version = "3.0.3".freeze
  s.summary = "Observability is a toolkit for instrumenting code to make it more observable, following the principle of Observability-Oriented Design as expressed by Charity Majors (@mipsytipsy)".freeze

  if s.respond_to? :specification_version then
    s.specification_version = 4

    if Gem::Version.new(Gem::VERSION) >= Gem::Version.new('1.2.0') then
      s.add_runtime_dependency(%q<concurrent-ruby>.freeze, ["~> 1.1.5"])
      s.add_runtime_dependency(%q<concurrent-ruby-ext>.freeze, ["~> 1.1.5"])
      s.add_runtime_dependency(%q<loggability>.freeze, ["~> 0.11"])
      s.add_runtime_dependency(%q<configurability>.freeze, ["~> 3.3"])
      s.add_runtime_dependency(%q<pluggability>.freeze, ["~> 0.6"])
      s.add_runtime_dependency(%q<msgpack>.freeze, ["~> 1.3"])
      s.add_development_dependency(%q<hoe-mercurial>.freeze, ["~> 1.4"])
      s.add_development_dependency(%q<hoe-deveiate>.freeze, ["~> 0.10"])
      s.add_development_dependency(%q<hoe-highline>.freeze, ["~> 0.2"])
      s.add_development_dependency(%q<timecop>.freeze, ["~> 0.9"])
      s.add_development_dependency(%q<simplecov>.freeze, ["~> 0.7"])
      s.add_development_dependency(%q<rdoc-generator-fivefish>.freeze, ["~> 0.1"])
      s.add_development_dependency(%q<rdoc>.freeze, [">= 4.0", "< 7"])
      s.add_development_dependency(%q<hoe>.freeze, ["~> 3.17"])
    else
      s.add_dependency(%q<concurrent-ruby>.freeze, ["~> 1.1.5"])
      s.add_dependency(%q<concurrent-ruby-ext>.freeze, ["~> 1.1.5"])
      s.add_dependency(%q<loggability>.freeze, ["~> 0.11"])
      s.add_dependency(%q<configurability>.freeze, ["~> 3.3"])
      s.add_dependency(%q<pluggability>.freeze, ["~> 0.6"])
      s.add_dependency(%q<msgpack>.freeze, ["~> 1.3"])
      s.add_dependency(%q<hoe-mercurial>.freeze, ["~> 1.4"])
      s.add_dependency(%q<hoe-deveiate>.freeze, ["~> 0.10"])
      s.add_dependency(%q<hoe-highline>.freeze, ["~> 0.2"])
      s.add_dependency(%q<timecop>.freeze, ["~> 0.9"])
      s.add_dependency(%q<simplecov>.freeze, ["~> 0.7"])
      s.add_dependency(%q<rdoc-generator-fivefish>.freeze, ["~> 0.1"])
      s.add_dependency(%q<rdoc>.freeze, [">= 4.0", "< 7"])
      s.add_dependency(%q<hoe>.freeze, ["~> 3.17"])
    end
  else
    s.add_dependency(%q<concurrent-ruby>.freeze, ["~> 1.1.5"])
    s.add_dependency(%q<concurrent-ruby-ext>.freeze, ["~> 1.1.5"])
    s.add_dependency(%q<loggability>.freeze, ["~> 0.11"])
    s.add_dependency(%q<configurability>.freeze, ["~> 3.3"])
    s.add_dependency(%q<pluggability>.freeze, ["~> 0.6"])
    s.add_dependency(%q<msgpack>.freeze, ["~> 1.3"])
    s.add_dependency(%q<hoe-mercurial>.freeze, ["~> 1.4"])
    s.add_dependency(%q<hoe-deveiate>.freeze, ["~> 0.10"])
    s.add_dependency(%q<hoe-highline>.freeze, ["~> 0.2"])
    s.add_dependency(%q<timecop>.freeze, ["~> 0.9"])
    s.add_dependency(%q<simplecov>.freeze, ["~> 0.7"])
    s.add_dependency(%q<rdoc-generator-fivefish>.freeze, ["~> 0.1"])
    s.add_dependency(%q<rdoc>.freeze, [">= 4.0", "< 7"])
    s.add_dependency(%q<hoe>.freeze, ["~> 3.17"])
  end
end
