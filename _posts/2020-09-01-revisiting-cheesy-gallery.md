---
title: "Jekyll Gallery Hosting pt6: revisiting cheesy-gallery"
category: programming
tags: devops hosting deployment applications jekyll programming git
---

Picking up [where I left off almost 8 months ago]({ link _posts/2020-01-19-git-annex.md }),
I started working with the cheesy-gallery source today.
Over the last couple of days I've mostly updated and cleaned up the Gemfile and travis-ci configuration while re-familiarising me with the [project](https://github.com/DavidS/cheesy-gallery/projects).

To reserve the name and put a line in the sand,
I've released [cheesy-gallery v0.5.0](https://rubygems.org/gems/cheesy-gallery) to rubygems.

The biggest success was integrating a lightbox into the new cheesy.at prototype templates.
This turned out to be a lot easier than I expected.
I went with [glightbox](https://biati-digital.github.io/glightbox/) which was quick to integrate and worked out of the box with minimal fussing.
The biggest issue was fixing the various examples I copied from to actually link up the selectors and run the code at the point in time during the page load where it'd actually do something.

I also implemented and reverted a mtime-based cache.
It turns out if I specify `--incremental`,
jekyll does the right thing (not regenerate unchanged images) on its own!

The last two(?) hours I spent trying to get git-annex to work on a non-bare repo on the main host to avoid a double checkout and the associated costs (2x50GB diskspace).
It turns out that my current hosting server has neither ruby 2.6 nor the most recent git-annex version.
I built a docker-compose container to deploy a debian testing image that has all the necessary modern bits installed,
has access to the git repo and can deploy the site
AND allows access using my ssh key without anyone noticing.
The deployment went well,
but git-annex was still very confused.
After all the various changes and tests and upgrades I did,
I probably need to start over and heed the lessons from [pt5]({ link _posts/2020-01-19-git-annex.md }) not using the assistant webapp to do the inital sync (and while testing not sync everything).

I might need to publish the cheesy.at git repo with all the attendant scripts for archival reasons.

You can see most of the work also in the [twitch archive](https://www.twitch.tv/videos/728001517),
which will be available for another two weeks.
