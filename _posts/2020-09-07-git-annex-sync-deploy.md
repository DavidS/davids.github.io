---
title: "Jekyll Gallery Hosting pt7: automated sync and deploy with git-annex"
category: programming
tags: devops hosting deployment applications jekyll programming git
---

After last week's [reintroduction]({% link _posts/2020-09-01-revisiting-cheesy-gallery.md %}) to the plugin,
today was focused on getting the data to and from the server.

In the morning session a complete re-init of the cheesy.at repo lead to great success using the git-annex webapp assistant to sync data to the repo on the server and update the checkout there.

In the afternoon session I worked on two major points: [fixing the symlink handling of jekyll](https://github.com/jekyll/jekyll/pull/8376)
and getting the docker container for deployment up to scratch to the point where I can now build the site.

The latter required a few additional build dependencies so the native extensions can build.
Now the site builds correctly on the hosting server:

```
root@33bb570ae200:/srv/cheesy.at/git# JEKYLL_ENV=production bundle exec jekyll build --strict --trace --incremental --destination ../site
Configuration file: /srv/cheesy.at/git/_config.yml
            Source: /srv/cheesy.at/git
       Destination: /srv/cheesy.at/site
 Incremental build: enabled
      Generating...
/var/lib/gems/2.7.0/gems/sorbet-runtime-0.5.5891/lib/types/private/methods/call_validation.rb:126: warning: Passing the keyword argument as the last hash parameter is deprecated
/var/lib/gems/2.7.0/gems/cheesy-gallery-0.5.0/lib/cheesy-gallery/gallery_index.rb:11: warning: The called method `read_content' is defined here
       Jekyll Feed: Generating feed for posts
     Build Warning: Layout 'nav_menu_item' requested in _posts/2014-04-25-21024.html does not exist.
     Build Warning: Layout 'nav_menu_item' requested in _posts/2014-04-25-21025.html does not exist.
     Build Warning: Layout 'nav_menu_item' requested in _posts/2014-04-25-21026.html does not exist.
     Build Warning: Layout 'nav_menu_item' requested in _posts/2014-04-25-21027.html does not exist.
     Build Warning: Layout 'nav_menu_item' requested in _posts/2014-04-25-home.html does not exist.
     Build Warning: Layout 'ecwd_event' requested in _posts/2015-11-05-rock-in-vienna.html does not exist.
     Build Warning: Layout 'ecwd_calendar' requested in _posts/2015-11-05-cd.html does not exist.
     Build Warning: Layout 'ecwd_event' requested in _posts/2015-11-05-u2.html does not exist.
     Build Warning: Layout 'ecwd_event' requested in _posts/2015-11-05-the-prodigy.html does not exist.
     Build Warning: Layout 'ecwd_event' requested in _posts/2015-11-05-bryan-adams.html does not exist.
          Conflict: The URL '/srv/cheesy.at/site/about/index.html' is the destination for the following pages: about.md, about/index.html
                    done in 13.425 seconds.
 Auto-regeneration: disabled. Use --watch to enable.
root@33bb570ae200:/srv/cheesy.at/git# rm -Rf _site/
root@33bb570ae200:/srv/cheesy.at/git# ls ../site/
2006  2009  2012  2015	2018	  about      feed.xml	 index.html
2007  2010  2013  2016	2019	  assets     fotos
2008  2011  2014  2017	404.html  export.rb  gaestebuch
root@33bb570ae200:/srv/cheesy.at/git#
```

Clearly there is still a lot to do.
This still needs to be automated on push,
and the generated site is not actually available online.
Configuring a test host will likely be my next step as this will allow me to show off the work already done.
(I also expect it to be pretty easy and give me a nice success boost.)
The automation of build will happen in a `post-receive` hook,
which will need to be careful about which pushes trigger it (git-annex is a bit chatty there),
whether all annexed content is already available,
and to maintain correct permissions when content is being pushed by different users.
Currently half of the site is owned by root, which is not great.
