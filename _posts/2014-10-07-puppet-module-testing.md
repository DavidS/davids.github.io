---
title: 'Puppet Module Testing'
category: puppet
tags: puppet testing
---

[[!meta title=""]]

Today I've invested a bit of time into getting modules back into shape. The
first was Alessandro's excellent
[puppet](https://github.com/example42/puppet-puppet) module. The
[PR](https://github.com/example42/puppet-puppet/pull/100) had six commits in
the end, fixing the various nits that travis complained about. Nothing fancy,
but annoying anyways. Now that this is green again, perhaps a little bit more
care with new contributions can be taken.

I've also added some other improvements I was sitting on for far too long:

  * [reports retention age](https://github.com/example42/puppet-puppet/pull/85)
  * [remove templatesdir setting](https://github.com/example42/puppet-puppet/pull/101)

Also, Alessandro has posted an [offer for shared maintainership on the example42 modules](http://us6.campaign-archive1.com/?u=17ca4725b2de64ee6f30c4e1d&id=a88e9949b9&e).
