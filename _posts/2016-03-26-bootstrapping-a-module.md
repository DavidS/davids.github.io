---
title: 'Re-Bootstrapping a Module'
category: puppet
tags: puppet testing retrospec
---

> Please note that this post is a linear and unedited brain dump of what I did. Many things might have changed meanwhile, and I may have learned how to do things better. This is an experiment in progress.

In an effort to refresh my hosting solution, I started looking at refreshing some of the modules I built back then. One thing I need to bring forward, for example is [The Olde Exiscan Module](https://github.com/DavidS/puppet-exiscan). Here's a log of what I did towards refreshing it to current standards, using [retrospec-puppet](https://github.com/nwops/puppet-retrospec).

# Install restrospec-puppet

Since the original module (see commits before today) was still using a `Modulefile` and had no test infrastructure at all, I started out by adding a minimal `Gemfile` and install retrospec-puppet:

```
david@zion:~/git/davids-exiscan$ ls
files  manifests  Modulefile  templates
david@zion:~/git/davids-exiscan$ cat Gemfile
source 'https://rubygems.org'

gem 'puppet-retrospec'
gem 'puppet'
david@zion:~/git/davids-exiscan$ bundle install --path=~/gems
Using awesome_print 1.6.1
Using facets 3.0.0
Using facter 2.4.6
Using json_pure 1.8.3
Using trollop 2.1.2
Using bundler 1.11.2
Using hiera 3.1.1
Using retrospec 0.4.0
Using puppet 4.4.1
Using puppet-retrospec 0.12.1
Bundle complete! 2 Gemfile dependencies, 10 gems now installed.
Bundled gems are installed into /home/david/gems.
david@zion:~/git/davids-exiscan$ bundle exec retrospec puppet --help
Generates puppet rspec test code based on the classes and defines inside the manifests directory.

Subcommands:
new_module
new_fact
new_type
new_provider
new_function
  -t, --template-dir=<s>        Path to templates directory (only for overriding Retrospec templates) (default:
                                /home/david/.retrospec/repos/retrospec-puppet-templates)
  -s, --scm-url=<s>             SCM url for retrospec templates (default: https://github.com/nwops/retrospec-templates)
  -b, --branch=<s>              Branch you want to use for the retrospec template repo (default: master)
  -e, --enable-beaker-tests     Enable the creation of beaker tests
  -n, --enable-future-parser    Enables the future parser only during validation
  -v, --version                 Print version and exit
  -h, --help                    Show this message
david@zion:~/git/davids-exiscan$
```

`new_module` kept breaking on the already existing code in the module, so I moved everything out of the way and just took the generated files:

```
david@zion:~/git/davids-exiscan$ bundle exec retrospec puppet new_module --name=davids-exiscan -a 'David Schmitt <david@black.co.at>'
Successfully ran hook: /home/david/.retrospec/repos/retrospec-puppet-templates/clone-hook

The module located at: /home/david/git/davids-exiscan does not exist, do you wish to create it? (y/n): y
 + /home/david/git/davids-exiscan/manifests/
 + /home/david/git/davids-exiscan/manifests/init.pp
 + /home/david/git/davids-exiscan/metadata.json
david@zion:~/git/davids-exiscan$ mv tmp/* ..
```

The metadata.json and .gitignore needed a few touches to add URLs and such. Then I could commit those changes to build upon them.

Trying to generate the tests, I ran into https://github.com/nwops/puppet-retrospec/issues/54 and started using the `future` branch, which already has puppet 4 vendored:

```
gem 'puppet-retrospec', git: 'https://github.com/nwops/puppet-retrospec.git', ref: 'future'
```

Almost:

```
david@zion:~/git/davids-exiscan$ bundle install --path=~/gems
Using awesome_print 1.6.1
Using facets 3.0.0
Using facter 2.4.6
Using json_pure 1.8.3
Using trollop 2.1.2
Using bundler 1.11.2
Using hiera 3.1.1
Using retrospec 0.4.0
Using puppet 4.4.1
Using puppet-retrospec 0.12.0 from https://github.com/nwops/puppet-retrospec.git (at future@a300496)
Bundle complete! 2 Gemfile dependencies, 10 gems now installed.
Bundled gems are installed into /home/david/gems.
david@zion:~/git/davids-exiscan$ bundle exec retrospec puppet
Successfully ran hook: /home/david/.retrospec/repos/retrospec-puppet-templates/clone-hook

Attempt to assign a value to unknown setting :parser
david@zion:~/git/davids-exiscan$
```

Some [quick code removal later](https://github.com/DavidS/puppet-retrospec/tree/remove-future-option) this problem is also fixed:

```
Using puppet-retrospec 0.12.0 from file:///home/david/git/puppet-retrospec (at future@a250574)
Bundle complete! 2 Gemfile dependencies, 10 gems now installed.
Bundled gems are installed into /home/david/gems.
david@zion:~/git/davids-exiscan$ bundle exec retrospec puppet
Successfully ran hook: /home/david/.retrospec/repos/retrospec-puppet-templates/clone-hook

Cloning into '/home/david/.retrospec/repos/puppet-git-hooks'...
remote: Counting objects: 524, done.
remote: Compressing objects: 100% (18/18), done.
remote: Total 524 (delta 6), reused 0 (delta 0), pack-reused 506
Receiving objects: 100% (524/524), 115.56 KiB | 0 bytes/s, done.
Resolving deltas: 100% (285/285), done.
Checking connectivity... done.
Successfully ran hook: /home/david/.retrospec/repos/retrospec-puppet-templates/pre-hook

!! /home/david/git/davids-exiscan/.bundle/config already exists
 + /home/david/git/davids-exiscan/.fixtures.yml
 + /home/david/git/davids-exiscan/.git/hooks/pre-commit
!! /home/david/git/davids-exiscan/.gitignore already exists and differs from template
 + /home/david/git/davids-exiscan/.puppet-lint.rc
 + /home/david/git/davids-exiscan/.travis.yml
 + /home/david/git/davids-exiscan/DEVELOPMENT.md
!! /home/david/git/davids-exiscan/Gemfile already exists
 + /home/david/git/davids-exiscan/Rakefile
 + /home/david/git/davids-exiscan/Vagrantfile
 + /home/david/git/davids-exiscan/files/.gitkeep
 + /home/david/git/davids-exiscan/spec/
 + /home/david/git/davids-exiscan/spec/acceptance/
 + /home/david/git/davids-exiscan/spec/shared_contexts.rb
 + /home/david/git/davids-exiscan/spec/spec_helper.rb
 + /home/david/git/davids-exiscan/templates/.gitkeep
 + /home/david/git/davids-exiscan/tests/
 + /home/david/git/davids-exiscan/tests/.gitkeep
 + /home/david/git/davids-exiscan/davids-exiscan_schema.yaml
Successfully ran hook: /home/david/.retrospec/repos/retrospec-puppet-templates/post-hook

david@zion:~/git/davids-exiscan$
```

Remember to replace the bootstrap `Gemfile` by retrospec's version. I generated a completely noew module and cribbed it from there.

Also, annoying, but understandable, is the lack of `puppet-retrospec` itself in the Gemfile. Since I haven't installed it in my system, I just re-added my reference to the local checkout I've been hacking on.

Additionally the template defaults to 3.x puppet, which also needed fixing. And https://github.com/nwops/retrospec-templates/pull/6 .

Generating tests now didn't fail anymore, but also didn't generate any tests. In the good old divide and conquer strategy, I've removed all manifests, which might not parse sanely, and replaced them by a trivial class, to see if that would work.

Having no luck with the future branch, I rolled back to the released puppet-retrospec gem and retried everything on a ruby (2.2) that was able to run puppet 3.7, the vendored version. Thankfully Debian provides ruby2.2 and ruby2.2-dev packages, so that was quite "painless".

Corey also hinted at yet [unreleased code that will fix](https://github.com/nwops/puppet-retrospec/pull/55#issuecomment-201893898) these pains.

Did I say "painless" ? ruby2.2 ALSO cannot run puppet 3.7

I've also tried building older versions of ruby with rbenv, a few weeks ago. Doesn't work, because those depend on SSLv2 functions that were removed upstream.

Instead I ripped out the vendored safe_yaml gem that is causing the ruby2.3 issues and replaced it with the normal safe_yaml 1.0.4. This required some persuasion (of the forced kind) so that puppet would start up, but since YAML is only used on the wire, we're not touching those parts anyways.

> side note: installing bundler and safe_yaml with gem2.2 from Debian into the 2.2 ruby install created `/usr/local/bin/bundler` causing even more "fun" after removing ruby2.2.

After more testing, it turned out that just adding safe_yaml to the Gemfile, or installing Debian's ruby-safe-yaml are enough to keep puppet from loading its broken vendored version.

At last the tests are running and are *finally* complaining about something that is wrong with the actual module itself: it can't find the `exim` module. A expected error as it is a dependency I did not migrate into the new metadata.json as it was replaced upstream with a [tp](https://github.com/example42/puppet-tp) plugin.


But that will be a story for another day.
