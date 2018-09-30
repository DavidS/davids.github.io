---
title: 'More rails'
tags: ruby rails programming
---

# More rails

Spend a few minutes searching for a nice autocompletion solution. Spent a few
more minutes to read the various ways people recommend installing
[JQuery](https://jquery.com/). Finally, someone recommends the [jyquery-rails
gem](https://rubygems.org/gems/jquery-rails), which already is installed in
rails4. Thanks. For nothing.

Finally, I settle on
[scoped\_search](https://github.com/wvanbergen/scoped_search). It seems pretty
powerful and complete. It is also used by the foreman. Following the tutorial
on the [example
application](https://github.com/abenari/scoped_search_demo_app), it is quite
easy to [get this running](https://github.com/DavidS/hrdb/commit/932d0f27623600db18ed54c6d6fa1bebabebee9f).

# Rendering fragments

Another issue I'd like to address is updating pages in situ, that is without a
full reload. [Github](https://github.com) has [implemented partial
reloads](https://github.com/blog/831-issues-2-0-the-next-generation) with
[PJAX](https://github.com/defunkt/jquery-pjax). This looks really nice, but I
think, I'll keep this complexity out of the code-base until I really need to
squeeze out the last bit of responsiveness.

# More testing

After reading too much about testing in rails, I've come to realize that all
the cool guys use [rspec-rails](http://rubydoc.info/gems/rspec-rails/frames)
with a boatload of tools. Rails by default gives you
[MiniTest](http://guides.rubyonrails.org/testing.html), which has no
integration with [guard](https://github.com/guard/guard). Good that I've not
really have coded any tests yet. Let's follow the rspec-rails intro for a while
and see how that works out.
[Commit](https://github.com/DavidS/hrdb/commit/aa0b83b7d2d6a1154ae3a12849ade00167f9ad3a).
Wow. Had to re-do almost everything since the scaffold generator stomps all
over. It brings many tests in the default scaffold. And they guided me to fix
them as required for the sorcery changes. Looking at codeclimate, I see a new
issue: the scaffold's default response blocks for `save` and `update` are
similar and complex enough, to push the whole PeopleController down to a C.
Also, code coverage slipped down another percent point, since the tests require
valid and invalid attribute examples, which I haven't yet provided. [Adding
those](https://github.com/DavidS/hrdb/commit/4f609d1c6f304f907471152d9f9d4ac6264c7778)
lead to a significant improvement in test coverage (35% to 85% for the
controller). The only untested code is the scoped\_search integration, which -
like the duplicate default responses - should be extracted into a separate
concern/aspect thingy.

[Updating the project
scaffold](https://github.com/DavidS/hrdb/commit/c16a965a952dffb6150344a4fb70af4c9f341821)
was comparatively easier, since the project has only a single field currently
and I already knew what I was doing.

On the codeclimate side, this raised the coverage above 90%, but added even
more complaints about the duplicated code. Not amused.

# Still unsolved: HABTM editing

I spent again a good time with uncle [Google](https://www.google.com/) but
still no luck on a good two-list control to edit the N:M relation for big Ns
and Ms (bigger than, say, five, which could be easily handled with checkboxes).

## Interlude

> I need to add some db:seeds, because entering new People by hand is really a
> drag.
> [Done](https://github.com/DavidS/hrdb/commit/6bd3e4ff0b0a98d337707ff1d72b710f73e10662).

## [The Plan](https://www.youtube.com/watch?v=I4MvAmNQFOs)

Since search and autocomplete already works for People, I'm gonna implement
this next for projects.
[Done](https://github.com/DavidS/hrdb/commit/d40c016a12a69bcf84707479e7d8d39fac20cd26).

Now I need a searchbox-plus-result-list-chooser control. That can chain up to a
controller action that adds a specified Person to a Project (or vice versa).
Fragment rendering's sweet siren call is playing in the background.

I finally
[implemented](https://github.com/DavidS/hrdb/commit/16dd4718144b97a6312dfe1f2307858ab4f86b5c)
a quite primitive post-back solution. As long as the responsiveness is good, it
works Good Enough for now.
