---
title: "Jekyll Gallery Hosting pt2: The best laid plans, of mice and persons ..."
category: programming
tags: devops hosting deployment applications jekyll programming
---

Following up on [last week's post](../2020-01-05-detailed-plans), today I'm gonna talk about the latest insights, hurdles and developments.

# Current Status

Last week I left off after getting some basic rendering working and linking up the newly generated `GalleryPage` instances into the jekyll `site`. After posting the write-up I did investigate a bit further, as I was having troubles getting the paths between the source and destination sorted out. Eventually I found that jekyll has a separate [`Document`](https://github.com/jekyll/jekyll/blob/654d3810395f2247a699b3aa3f828bc6d1ef30f6/lib/jekyll/document.rb) class that takes care of entries in [collections](https://jekyllrb.com/docs/collections/), which does handle path handling when the source is a underscore-directory, but duplicates/re-implements a lot of the remaining functionality, but differently.

To stay as close as possible to the original plan, I'll substitute and `Page` for `Document` and see whether that fixes the path-translation issues I've been encountering when building the site. If that doesn't work out, I'll have to go back and modify the design and workflow of the generator. Maybe putting the entire `_galleries` folder content instead directly into the site and only go back and patch-up already instantiated `Pages` also works? This might even give more flexibility in the long-run, as any layout/page could access the new data for any images in that page/tree. Decision anxiety is a thing :-(, I've been on-and-off mulling over this for the last few days and both approaches have their merit. I'll need to build (at least some of) both to test my assumptions.

# Progress

I'll start with replacing the `Page`s with `Document`s. This seems to be the smaller operation and will give me a better understanding of the feasibility of this and what else is there in `Document`.

[Collections](https://jekyllrb.com/docs/collections/) are configured by adding an entry in the `_config.yml`:

```
collections:
  - galleries
```

doing so already creates an instance of `Jekyll::Collection` in `site.collections['galleries']` that has entries for every file in the directory tree:

```
[7] pry(#<Jekyll::Collection>):1> entries
=> [".",
 "first",
 "first/.",
 "first/Halloween13-39.jpg",
 "first/2012-07-29-Eingeschlafen.jpg",
 "first/index.html",
 "second",
 "second/.",
 "second/Frostig-001.jpg",
 "second/Frostig-003.jpg",
 "second/third",
 "second/third/.",
 "second/third/Morgenspaziergang-2.jpg",
 "second/third/Morgenspaziergang-3.jpg"]
[8] pry(#<Jekyll::Collection>):1>
```

but there is no rendering of anything happening, as the documentation helpfully points out. To change that we need to set `output: true` on the collection:

```
collections:
  galleries:
    output: true
```

and lo and behold, the index is rendered without any functionality in the cheesy-generator:

```
david@zion:~/Projects/cheesy-gallery/spec/fixtures/test_site$ cat _galleries/first/index.html
---
x_layout: gallery
title: "The first Gallery"
---
This is a test gallery. The first of its kind.
david@zion:~/Projects/cheesy-gallery/spec/fixtures/test_site$ cat _site/galleries/first/index.html
This is a test gallery. The first of its kind.
david@zion:~/Projects/cheesy-gallery/spec/fixtures/test_site$
```

I've disabled layouting with the `x_` prefix there to avoid a lot of irrelevant HTML, but enabling it does do the right thing and applies the layout tree through Liquid.

Image data, of course, is passed through unmodified.

The `docs` attribute on the `Collection` contains all `Document` instances. There is one for the `first/index.html`, but none for the image-only directories. The `files` attribute contains all `StaticFile` instances.

Another annoying quirk is that `entries` is a flat array. The documentation explains how to iterate over that in Liquid.

The documentation enumerates a few other attributes a collection entry (i.e. `Document`) can have. None of them specifically useful to the nested gallery usecase.

In [this commit](https://github.com/DavidS/cheesy-gallery/commit/d95692f21c25fb677b7748a350afca55e6dcd584) I implement all that I thought I had last weekend, but didn't work, in a really nice and clean fashion:

```
def generate(site)
  @site = site
  collection = site.collections['galleries']

  # all galleries in the site
  galleries = Set[*collection.entries.map { |e| File.dirname(e) }]

  # all galleries with an index.html
  galleries_with_index = Set[*collection.entries.find_all { |e| e.end_with?('/index.html') }.map { |e| File.dirname(e) }]

  # fill in Documents for galleries that don't have an index.html
  (galleries - galleries_with_index).each do |e|
    doc = CheesyGallery::GalleryIndex.new(File.join('_galleries', e, 'index.html'), site: site, collection: collection)
    doc.read
    collection.docs << doc if site.unpublished || doc.published?
  end

  files_by_dirname = {}
  collection.files.each { |e| (files_by_dirname[File.dirname(e.relative_path)] ||= []) << e }

  collection.docs.each do |doc|
    # attach images
    doc.data['images'] = files_by_dirname[File.dirname(doc.relative_path)]
  end
end
```

First, `galleries` and `galleries_with_index` are calculated to be able to create new `CheesyGallery::GalleryIndex` instances for galleries that do not have a `index.html`. Then, the new Documents get created to fill in the blanks. Since jekyll maintains everything in flat lists, `files_by_dirname` is used to make the image linking easier. Finally, the `images` attribute is filled with all files belonging to a specific document.

In the `gallery.html`, I make some changes to show the images as an example how it can be used. For the next time I get around to this, I update the [project on github](https://github.com/DavidS/cheesy-gallery/projects/1) with what I managed today and enhance the description of what to do next, as well as a couple of ideas for going forward.
