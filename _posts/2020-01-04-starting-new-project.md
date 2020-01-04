---
title: "Jekyll Gallery Hosting pt1: Preface"
category: programming
tags: devops hosting deployment applications jekyll programming
---

[The Wife](http://www.cheesy.at) is running a [WordPress](https://en-gb.wordpress.org/) site with over 700 blog posts, recipies and galleries containing over 50GB of pictures on my old hosting server. Between WordPress complaining about PHP being too old to upgrade and myself wanting to get that site off the old infrastructure, I've started looking into migrating her page to a less resource-hungry, easier to maintain solution. Since this blog here is running on jekyll, I thought I'll give it a try.

Over the holidays I did a lot of research and experimentation, and now I'm finalising the plan to do so:

* Use the [jekyll<-WordPress](http://import.jekyllrb.com/docs/wordpress/) importer to download all posts from the old site. This is working OK and generates markdown files for each blog post and page. One issue to address is that the importer is confused about where to clean up HTML entities and where not. While this might need manual intervention before the switch-over, it'll be a one-time global search&replace operation, so I'm not overly concerned.

* Port the theme over. This will be a wholly manual process. Since the original site already is styled and there is no interest in changing the theme, this will be rather straight-forward (famous last words). Lift&shift into sass and git will hopefully mean an easier time maintaining it going forward - as opposed to the web-based theme editor of wordpress with no version control.

* Keep everything in version control. For the base posts and pages, I'll use git. For the image data, I'm planning on using [git-annex](https://git-annex.branchable.com/) to keep the repo size manageable.

* Find a solution for the galleries. This one as it turned out was a lot more complicated than I initially thought, as Christine's galleries far exceed the capabilities of any existing solution.

* Add a server-side push hook to build and deploy the website when a new revision is uploaded. I could use this for my own blog too, as I'm still manually building and rsyncing from my workstation :-D

This post is a rough summary of my research until now and a sketch of a solution for the galleries. I'll follow up with more posts as I progress through development.

# Existing Jekyll Gallery Solutions

Recommendations from a [jekyll forum thread](https://talk.jekyllrb.com/t/jekyll-photo-gallery/1499):
* [CloudCannon gallery](https://learn.cloudcannon.com/jekyll/photo-gallery/):
* [ggreer/jekyll-gallery-generator](https://github.com/ggreer/jekyll-gallery-generator)
* [aerobless/jekyll-photo-gallery](https://github.com/aerobless/jekyll-photo-gallery)
* [alexivkin/Jekyll-Art-Gallery-Plugin](https://github.com/alexivkin/Jekyll-Art-Gallery-Plugin)

That thread has a few other recommendations that look even less appealing than these.

Other projects I've looked at:
* [rbuchberger/jekyll_picture_tag](https://github.com/rbuchberger/jekyll_picture_tag)

As far as I can tell after investigating those projects, they all fall flat on one or more of the following points:

* Can handle only a single gallery - Christine has hundreds of folders of pictures
* Needs manual data entry do add pictures to galleries - Christine has the pictures sorted into folders already
* Pictures are not optimized on build - Christine is using pictures from a DSLR, and even mobile phone cameras today can produce quite hefty images
* Optimized picture cache is not handled properly - Projects either have no cache or do not expire the cache. Both unacceptable given the size of the site
* Unmaintained crap

# Other static site generators

* [HUGO](https://gohugo.io): while claiming to have a lot of built-in functionality, it does not provide a gallery. The [only external plugin I could find](https://github.com/liwenyip/hugo-easy-gallery) is currently looking for help with maintenance.

* [Gatsby.js](https://www.gatsbyjs.org/): while claiming to have loads of plugins, it only has one gallery plugin which seems to be suffering from the same issues plaguing the jekyll plugins.

# Jekyll Architecture

jekyll itself is a wrapper around the Liquid templating language. Being two separate projects might be nice from a maintainability standpoint (liquid is a shopify project, jekyll a github.com project), but this split is not great for extensibility and understanding the architecture.

tl;dr: During each site build, jekyll loads all data into a memory structure (a [`Jekyll::Site`](https://github.com/jekyll/jekyll/blob/master/lib/jekyll/site.rb) instance) with [`Jekyll::Page`](https://github.com/jekyll/jekyll/blob/master/lib/jekyll/page.rb) entries for every markdown file and [`Jekyll::StaticFile`s](https://github.com/jekyll/jekyll/blob/master/lib/jekyll/static_file.rb) for everything else. Additional data gets loaded into [collections](https://jekyllrb.com/docs/collections/), which will be available in the [layouts](https://jekyllrb.com/docs/structure/) through the `site` object.

[Generators](https://jekyllrb.com/docs/plugins/generators/) act on the built `site` data structure before it is rendered to the target directory. [Tags](https://jekyllrb.com/docs/plugins/tags/) extend the liquid templating language.

# First Wrap-up

Looking back at all that, I think the various projects' shortcomings can all be directly traced to those architectural choices:

* rbuchberger/jekyll_picture_tag: this is only a liquid tag that does all the picture crunching during the render stage. Therefore it can't change the `site` structure anymore and is outside the caching/incremental build support jekyll provides. It also means there is no way to theme the output of the tag, as there is also no connection to jekyll's layout system.

* alexivkin/Jekyll-Art-Gallery-Plugin: looks like an unmaintained 2016 rip-off of ggreer's plugin to me. hard pass.

* aerobless/jekyll-photo-gallery: requires adding each gallery to the site config, then renders from that information

* ggreer/jekyll-gallery-generator: replaces some entries in the `site` object with custom instances that add gallery functionality. For some unknown-to-me reason the plugin does not support nested galleries and does write out the site pages while adding new `GalleryPage` objects to the `site`. I tried to add nested galleries, but soon floundered on the details as nothing in the plugin's structure is prepared for that.

# The Plan

After a good two or three days of research I therefore resign myself to the fact that I want to implement a jekyll gallery plugin myself:

* Create a new gallery by adding a folder of pictures.

* Support a nested folder/gallery structure.
  * Find nested galleries.
  * Build a page tree to navigate through galleries.
  * Custom thumbnail for each gallery.

* Optimize picture files for multiple display sizes.

* Allow mixing in some text into the gallery index pages.

* Expose everything through jekyll's layout system.

* Allow easy linking to specific pictures from any page across the site.

* Provide the same tools for individual pictures attached to pages (rather than being hosted in a full gallery).

# Resources

All the other links:

* [Jekyll](https://jekyllrb.com/)
* [Jekyll Repo](https://github.com/jekyll/jekyll)
* [SASS](https://sass-lang.com/guide)
* [Liquid](https://shopify.github.io/liquid/) ; [for programmers](https://github.com/Shopify/liquid/wiki/Liquid-for-Programmers)
* [HTML spec](https://html.spec.whatwg.org/multipage/)
* [data schemas](http://schema.org/)
* [CSS Reference](https://www.w3schools.com/css/default.asp)
