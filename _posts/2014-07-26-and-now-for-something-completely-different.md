---
title: 'And now for something completely different'
tags: ruby rails testing programming
---

And now for something completely different. For a private project, I'm trying
out ruby on rails. Here's a link and brain dump of stuff I did.

Start on [Get Ruby on Rails in no time](http://rubyonrails.org/download/).
I'm working on my Debian jessie (testing) machine, where I already have
[rbenv](https://github.com/sstephenson/rbenv) installed, so I just create a new
directory `rails`, which will contain my rails
[gemset](https://github.com/jf/rbenv-gemset).

Inside I can install rails and create a new application as directed. Of course,
the rails server does *not* start as advertised.
[ExecJS](https://github.com/sstephenson/execjs) is pining for a JS runtime,
takes no prisoners and aborts everything with a stacktrace.

    $ sudo aptitude install nodejs

Thank you, [Debian](http://www.debian.org/)!

The server works now, and the default main page loads explaining that it works.
Nice. I
[commit](https://github.com/DavidS/hrdb/commit/3cf490746ef914cc6b4e872dbe827f73de04e8e5)
everything to a new [git repo](https://github.com/DavidS/hrdb) to be able to
see what will happen with the project. Since the initial instructions on this
page show the right direction, but no detail, I follow the link to the [Rails
Guides](http://guides.rubyonrails.org/) where I start with the [Getting Started
with Rails](http://guides.rubyonrails.org/getting_started.html) tour. The first
sections can be skipped, as the server is already running. The interesting part
begins with actually creating the first controller with `rails generate controller`.
It automatically inserts a default route into the configuration.
[Commit](https://github.com/DavidS/hrdb/commit/fbf2e4bceddc6d15cb16e7975995e0ca2d1b2e1e).
Enabling it as the default route for `/` is explained next.
[Commit](https://github.com/DavidS/hrdb/commit/2d766b4377d634b92a7695af6cc0afcc31e1385a).
RoR is talking to me.

# Resources

Now the meat of the framework is revealed.
[Resources](http://guides.rubyonrails.org/getting_started.html#getting-up-and-running)
are the
[CRUD](https://en.wikipedia.org/wiki/Create,_read,_update_and_delete)-able
contents of the new app. I start with the ever popular "people" resource and
add a default resource route and an empty controller.
[Commit](https://github.com/DavidS/hrdb/commit/f7b3c95e5d7913ac18ec290c8c40cd5c61f30a81).

Browsing through the new files, I notice that rails has helpfully created empty
test harnesses for me. I configure the repo for
[travis-ci](https://travis-ci.org/DavidS/hrdb).
[Commit](https://github.com/DavidS/hrdb/commit/98561c3620ef6e5aff53ab1f6d5b49697d512676).
As there is only a single default test, the build passes with flying colors for
ruby 2.1 and ruby 1.9. [JRuby](http://jruby.org/) chokes on the native sqlite
extension. As JRuby is not my primary target, I just disable it again. I will
need to have some coverage testing set up too.

# [Get on with it!](https://www.youtube.com/watch?v=dEtm_Q2LK9g)

Following the guide, I create the first empty controller action.

> Note: something in this project makes ruby use gem references in stack traces
> instead of mile-long paths. Very nice.

Time passes. Documentation is read. Code is written.

Nice, RoR seems to have learned some lessons: there is a built-in POST params
validator. No `global_vars` fiasco here. Instead it just doesn't work. I spend
some time reading [more on strong
parameters](http://weblog.rubyonrails.org/2012/3/21/strong-parameters/) which
uses slightly different method call (`required` instead of `require`). This
doesn't work either. No stacktrace too. Hmm. Welcome to the real world.

The [official documentation](https://github.com/rails/strong_parameters) uses
`require` consistently, so I go with that. Even copy and pasting the example
from the [Action Controller
overview](http://guides.rubyonrails.org/action_controller_overview.html#strong-parameters)
(which coincidentally matches my model) doesn't help. Still no proper
stacktrace or other hint. Except that there is a "Full Trace" link, right below
the error message on the rendered 500 error page. D'oh!. I dive into the
underlying source. Glossing over the
`active_model/forbidden_attributes_protection.rb` file, which actually throws
the error doesn't help much.

Another look at the code and guide finally reveals the problem: the new
`person_params` method must be used to access the params. There is no magic to
inject that call into the execution. I'm a little disappointed but I can live
with that.
[Commit](https://github.com/DavidS/hrdb/commit/26a24ef10d73893859c78b5ddde8045ef662e994).

The next piece is loading the new record from the database and creating a view
for it.
[Commit](https://github.com/DavidS/hrdb/commit/7af7d7012863017d87a061d7d579bc1d5cf6279c).

The guide now covers some basic things like programmatic linking to actions and
paths, model validation, updating and deleting resources. I'm starting to gloss
over things as I'm running out of time for now. Doesn't help.

Finally, I look into authentication/authorization solutions for rails. Built-in
is a single-user basic http authorization, which is not very helpful for my
use-case. The guide recommends
[Devise](https://github.com/plataformatec/devise) or
[Authlogic](https://github.com/binarylogic/authlogic). Devise is a full blown
MVC engine while Authlogic has no successful build on travis since adding the
travis badge back in April. I've also looked at [The Foreman's
Authentication](https://github.com/theforeman/foreman/blob/develop/app/controllers/concerns/foreman/controller/authentication.rb)
stuff, but they have coded up a complete custom AAA framework. I'm still
undecided between going the manual route, implementing authorization in custom
code while delegating authorization to the container or using Authlogic, which
looks much more rails-like than Devise. This will need more experimentation.

Enough for today, [I know rails](https://www.youtube.com/watch?v=6vMO3XmNXe4)!

TODO:

* coverage tests
* code climate
* add license
