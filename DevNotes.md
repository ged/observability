# Developer Notes

Characteristics of an observation:

* Should it be timed?
* What kinds of event models to support:
  - Process: PID, PPID, PGID, rusage stuff
  - Thread: Thread ID, PID, thread group ID, name, priority, thread_variables
  - Net: Local IP, Peer IP, socktype, family, protocol, flags


## Implementation

Classes which are Observable will:

* Create an "observer" Module that contains all of its observation hooks
* Prepend the module onto the Observable class and its subclasses
* Expose an instance method #observer that returns the module
* Keep pending events and adds data to the innermost one via #observer.add

The Observability module will:

* Allow configuration of a sink to send events to
* No-op if no sink is configured
* Provide pluggable abstractions to:
  - Provide the formatting of events
  - Provide the transport to the event store


## Possible Datapoints

* Cardinality
  - UUIDs
  - db raw queries
  - normalized queries
  - comments
  - PID/PPID
  - app ID
  - device ID
  - HTTP headers
  - build ID
  - IP:port
  - userid
* Context
  - 
* Structured data
* Tracing+events

 