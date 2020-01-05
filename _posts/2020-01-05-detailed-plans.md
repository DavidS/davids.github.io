---
title: "Jekyll Gallery Hosting pt2: Technical Planning"
category: programming
tags: devops hosting deployment applications jekyll programming
---

This post contains the more detailed technical planning and how successfull those ideas were.

# The Plan

These are the points from the [last post](2020-01-04-starting-new-project) that I want to hit with my implementation:

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

# Implementation Map

Following the insights from my work leading the [last post](2020-01-04-starting-new-project), this is how I expect the new plugin to work:

* setup: a `_galleries` folder hosting all pictures
* generator: load that folder into the `site` object
* generator: build a `page` tree referencing each of the folders/galleries
* code: have a `StaticFile` equivalent for managing picture rendering on `write`
* generator: add such image file instances for each picture
* layout: provide page templates for a gallery and a picture page
* let jekyll render everything
* ???
* profit!

# Project Start Up

* created a new github repo for [cheesy-gallery](https://github.com/DavidS/cheesy-gallery) and set up a new gem, [travis](https://travis-ci.org/DavidS/cheesy-gallery), [codecov](https://codecov.io/gh/DavidS/cheesy-gallery), rubocop and [dependabot](https://app.dependabot.com/accounts/DavidS/repos/231789729) ([homepage](https://dependabot.com/)).

* created a new project for cheesy-gallery to capture the even more detailed planning: [https://github.com/DavidS/cheesy-gallery/projects/1](https://github.com/DavidS/cheesy-gallery/projects/1)

* Started on building a simple integration test setup with a [test site](https://github.com/DavidS/cheesy-gallery/tree/master/spec/fixtures/test_site) and a quick [build step](https://github.com/DavidS/cheesy-gallery/blob/d39a44cf33bea0ea3909b51016c64168e34c211b/.travis.yml#L13-L20) on travis.

* Managed to knock out the [first programming step](https://github.com/DavidS/cheesy-gallery/projects/1#card-31178444) on the board, even though I was severly distracted by watching TV :-D

# Current status

So the plugin already can correctly recreate the directory structure of the `_galleries` input folder and use a provided layout. Given my current architectural understanding of jekyll, I'm pretty chuffed to get this done in a (very relaxed) weekend.

The most important insight of this work was realising that - and understanding why - jekyll plugins can't supply layouts. Initially my expectation was that I could add `GalleryPage` instances, declare/request a `gallery` layout and provide a `_layouts/gallery.html` liquid template in the gem. As it turns out, jekyll has no provisions for this. The key limitation, I believe, is that the `gallery.html` liquid template would have to link up the the `default.html` layout from the theme. Since between the user and the theme there is no true "main" template that this could link up to. Is it a `page` or a `default` or maybe something completely else? My next though now is that I'll manually design a layout to render a gallery and a picture page and provide that as an example. At the same time it might be nice to have a set of liquid tags that render a default view and reduce the maintenance amount for site owners. This would also reduce the API surface that I'd need to maintain.

# Next steps

As next steps, I've planned out [list and show images in gallery page
](https://github.com/DavidS/cheesy-gallery/projects/1#card-31200100) and [Page Tree Nav](https://github.com/DavidS/cheesy-gallery/projects/1#card-31178448) with more details of expected implementation.
