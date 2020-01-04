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

# Project Setup

* created a new github repo for [cheesy-gallery](https://github.com/DavidS/cheesy-gallery) and set up a new gem, travis, codecov, rubocop and dependabot.

* created a new project for cheesy-gallery to capture the even more detailed planning: [https://github.com/DavidS/cheesy-gallery/projects/1](https://github.com/DavidS/cheesy-gallery/projects/1)
