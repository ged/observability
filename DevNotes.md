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

 
## Event Naming Convention

Event names are dot-separated namespaces for events. You can use any convention that makes sense for your organization, but we suggest a convention like:

    <namespace>.<system>.<verb>[.<detail>]+

For a class named `FM::Manager::Players`, an event sent for a method called
`connect_player` might be:

    fm.manager.players.connect_player

And an exception raised from that method call might generate:

    fm.manager.players.connect_player.exception

For the Sequel database toolkit, establishing a PostgreSQL connection might generate an event named:

    sequel.adapters.postgres.connect

and if the connection subsequently failed, it might be followed with:

    sequel.adapters.postgres.connect.failure


## Event "Models"

If you pass a `:model` option when creating an event, you can pre-populate an event with a bunch of useful datapoints. Some ideas for models:


`process`
: Adds information about the current process: e.g., `getrusage(2)` deltas, `pid`, `pgid`, `ppid`, `uid`, `euid`, `egid`, `utime`, `stime`, `cutime`, `cstime`
: The context should be a method that is called when a process starts and which returns when the process is going to shut down or has been shut down.

`loop`
: Adds information about the execution of a loop: e.g., `getrusage(2)` deltas, GC stats, etc.
: It should be created immediately inside the loop to be measured.

`thread`
: Adds information about the execution of a thread: e.g., thread ID, name, priority, etc.



## Unresolved Issues

- How should events sent from class methods be distinguished from instance methods of the same name?
- The object ID used for the event name for events sent from wrapped methods of singleton methods of anonymous classes is that of the singleton class, not the anonymous class itself. Given how infrequent this will be the case I'm not sure it's worth solving.
- Is it worth the additional cost of duping arguments to callbacks of wrapper methods to ensure they don't accidentally modify them?
- Make observing with a null sender be more no-opish.






