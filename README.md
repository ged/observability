# Observability

home
: https://hg.sr.ht/~ged/Observability

code
: https://hg.sr.ht/~ged/Observability/browse

github
: https://github.com/ged/observability

docs
: http://deveiate.org/code/observability


## Description

Observability is a toolkit for instrumenting code to make it more observable.
It follows the principle of Observability-Oriented Design as expressed by Charity
Majors (@mipsytipsy).

Its goals are stolen from https://charity.wtf/2019/02/05/logs-vs-structured-events/:

* Emit a rich record from the perspective of a single action as the code is
  executing.
* Emit a single event per action per system that it occurs in. Write it out just
  before the action completes or errors.
* Bypass local disk entirely, write to a remote service.
* Sample if needed for cost or resource constraints. Practice dynamic sampling.
* Treat this like operational data, not transactional data. Be profligate and
  disposable.
* Feed this data into a columnar store or honeycomb or similar
* Now use it every day. Not just as a last resort. Get knee deep in production
  every single day. Explore. Ask and answer rich questions about your systems,
  system quality, system behavior, outliers, error conditions, etc. You will be
  absolutely amazed how useful it is … and appalled by what you turn up. 🙂

[![builds.sr.ht status](https://builds.sr.ht/~ged/Observability.svg)](https://builds.sr.ht/~ged/Observability?)


## Prerequisites

* Ruby 2.6


## Installation

    $ gem install observability


## Contributing

You can check out the current development source with Mercurial via its
[project page][sourcehut]. Or if you prefer Git, via
[its Github mirror][github].


## Author

- Michael Granger <ged@faeriemud.org>


## License

Copyright (c) 2019, Michael Granger
All rights reserved.

Redistribution and use in source and binary forms, with or without
modification, are permitted provided that the following conditions are met:

* Redistributions of source code must retain the above copyright notice,
  this list of conditions and the following disclaimer.

* Redistributions in binary form must reproduce the above copyright notice,
  this list of conditions and the following disclaimer in the documentation
  and/or other materials provided with the distribution.

* Neither the name of the author/s, nor the names of the project's
  contributors may be used to endorse or promote products derived from this
  software without specific prior written permission.

THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER OR CONTRIBUTORS BE LIABLE
FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL
DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR
SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER
CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY,
OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE
OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.


[sourcehut]: https://hg.sr.ht/~ged/Observability
[github]: https://github.com/ged/observability

