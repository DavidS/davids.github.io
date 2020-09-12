---
title: "Jekyll Gallery Hosting pt8: automated deploy with git-annex"
category: programming
tags: devops hosting deployment applications jekyll programming git
---

Today has been a mixed bag of stuff.
For the next two weeks you can find the stream on [my twitch channel](twitch.tv/dev_el_ops/videos).

**Automated updates:** Created a quick [`post-receive` hook](https://git-scm.com/book/en/v2/Customizing-Git-Git-Hooks) to update the site when git-annex syncs:

```ruby
#!/usr/bin/env ruby

require "open3"

pushed_refs = $stdin.readlines

output, status = Open3.capture2e("git annex post-receive", stdin_data: pushed_refs.join("\n"))

Dir.chdir('/srv/cheesy.at/git')
system("bundle config set path /srv/cheesy.at/gems")
system("bundle install")
system("JEKYLL_ENV=production bundle exec jekyll build --strict --trace --destination /srv/cheesy.at/site --verbose --incremental")
```

[This](https://github.com/DavidS/cheesy.at/blob/244858cace4dd76515731dbfa7fdd509b97cbf73/bin/post-receive.rb) does the `git annex post-receive` default updates which (I assume) put all the files in place.
Afterwards it configures the gem cache,
installs the bundle,
and runs a incremental site build.

On my tests with `git annex sync --content` this worked fine and updated the test site with the new files.

**Public test site:** I've also puttered around with adding a new site [`test.cheesy.at`](https://github.com/DavidS/dasz-configuration/commit/0eeabaf1af9ed2b43c8ab738b963c2455db49bfc) to host the in-progress work, but screwed up the DNS configuration and am still waiting on [Let's Encrypt](https://letsencrypt.org/)'s verification systems to refresh their cache.
Luckily this refresh happened while I was still here, so [https://test.cheesy.at/](https://test.cheesy.at/) is now deployed and secured.
See the following commits for some more tweaking required to get it working.
The actual private keys are deployed through a separate private repo that is not shared.

**Persistent SSH hostkeys:** Finally I've added [some code](https://github.com/DavidS/cheesy.at/commit/4c4683a49b6eaaef90e075c04707ad4fc43e775f) to the Dockerfile to preserve ssh host keys across rebuilds.
The keys, again, are stored outside the published repo.
Without this change, everytime a new version of the docker container is started, it would give nasty errors about the SSH host keys being changed.
