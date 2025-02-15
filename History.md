# Release History for observability

---
## v0.4.0 [2025-02-14] Michael Granger <ged@faeriemud.org>

Fixes:

- Update for latest configurability, Ruby 3.4 compatibility


## v0.3.0 [2020-02-21] Michael Granger <ged@faeriemud.org>

Improvements:

- Add `requires` to instrumentation, add a PG instrument
- Add an event ID for cross-application context
- Update for Ruby 2.7.

Bugfixes:

- Add a provisional fix for observing arity-0 methods
- Guard against blockless observe calls


## v0.2.0 [2019-10-16] Michael Granger <ged@faeriemud.org>

Improvements:

- Add an experimental rabbitmq collector
- Add a udp multicast sender
- Handle exceptions with a #cause
- Add instrumentation API
- Update the timescale store schema


## v0.1.0 [2019-07-23] Michael Granger <ged@FaerieMUD.org>

Initial release.

