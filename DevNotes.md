# Developer Notes

Characteristics of an observation:

* Should it be timed?
* What kinds of event models to support:
  * Process: PID, PPID, PGID, rusage stuff
  * Thread: Thread ID, PID, thread group ID, name, priority, thread_variables
  * Net: Local IP, Peer IP, socktype, family, protocol, flags


Classes which are Observable will:

* Create an "observer" Module that contains all of its observation hooks
* Prepend the module onto the Observable class and its subclasses
* Expose an instance method #observer that returns the module
* Keep pending events and adds data to the innermost one via #observer.add



