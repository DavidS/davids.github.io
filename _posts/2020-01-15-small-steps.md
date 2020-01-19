---
title: "Jekyll Gallery Hosting pt4: Small Steps"
category: programming
tags: devops hosting deployment applications jekyll programming
---

Following up on [the last post](../2020-01-11-plans-of-mice-and-persons), today I'm catching up on reporting my latest activities.

# Current Status

Last weekend was pretty annoying insights and also good research success. On Moday I could [add another evening of work](https://twitter.com/dev_el_ops/status/1216807365787496453) and got some things done:

```
~/Projects/cheesy-gallery$ git log --oneline
e014c6c (HEAD -> master, origin/master) link up sub-pages for tree navigation; add links to gallery.html
13e2379 apply default layout to empty index galleries
5baa3ea Let rubocop sort out my laziness
9e23612 fix bug where main gallery was not correctly identified
210ccdb avoid wrecking parent relationships with additional pages
de23b14 whitespace fixes
e9f7c08 add 'parent' to each gallery; add parent link to gallery.html
```

With these changes in place, the gallery pages now get proper tree navigation where you can jump from any index to its parent, and all sub-pages.

# Next Steps

With the new confidence, I did some planning and rearranging on [the board](https://github.com/DavidS/cheesy-gallery/projects/1). The next thing will be a bigger jump with ["render thumbnails for pictures"](https://github.com/DavidS/cheesy-gallery/projects/1#card-31583024). This will make the gallery more presentable and start approaching something that actually works. I'm planning on following other project's lead and use rmagic for the image manipulation. The goal is for each image in a gallery render out a square thumbnail in a (configurable??) size and attach enough information about that thumbnail to the `images` information so that the layout can use the thumbnail as link to the actual picture. This should end up very similar to how the [current gallery](http://www.cheesy.at/fotos/leben-in-belfast/2019-2/sonniger-und-frostiger-letzter-tag-im-jahr/) looks like.

While I'm now confident about the basics, I'm wondering how the thumbnail rendering will fit into the incremental rendering. I've stumbled over `Drops` while browsing through the object tree, which seem to represent the target file before it is written? Tune in on the weekend to see me figure it out, or fail hilariously!
