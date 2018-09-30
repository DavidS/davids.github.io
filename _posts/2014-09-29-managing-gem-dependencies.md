---
title: 'Managing gem dependencies'
tags: ruby programming testing security docker
---

Following a struggle of getting (the right combination of) ruby gems to
install, I've checked out solutions to gem dependency management tonight. A
common thing seems to be [gemnasium](https://gemnasium.com) which is running a
check on the Gemfile (and presumably the gemspec too) to report on the
up-to-dateness of the dependencies.

The free version seems to offer tracking of unlimited public projects. I've
configured it for [hrdb](https://gemnasium.com/DavidS/hrdb) and I immediately
found a warning for a security issue in one of the not-yet-updated
dependencies. A `bundle update`,
[commit](https://github.com/DavidS/hrdb/commit/4bfbab5429d6be08f53f651fa318dbae0c06004a),
push, and a refresh of the report later, this problem is fixed too.

# coveralls

Meanwhile I've tested [coveralls](https://coveralls.io/) instead of code
climate's code coverage service. Usage is exactly the same (modulo actual
letters typed):

  * Add gem
  * Add include and call to `spec_helper.rb`

coveralls is slightly slower than code climate (5 min 4 sec vs. 4 min 54 sec).

coveralls definitely has more details and a nicer style sheet on its page,
while on code climate, the coverage display is integrated into the problem
displayer which makes it easier to correlate these checks.

I'll stay with code climate for now.

# docker

In other news, I've had an in-depth look at docker in a realistic use case and
am quite impressed by the smoothness of the experience and the low latency
features. For example, rebuilding images after small changes to the Dockerfile
does not require redoing commands from an unchanged prefix of the Dockerfile.
That is, if the Dockerfile starts with installing 100 packages, and later you
need to add a few more (to the "same" image), adding the additional packages in
a separate RUN command will cause docker to automatically reuse intermediate
images from the last build to reduce the time to finish.
