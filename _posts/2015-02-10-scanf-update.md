---
title: 'scanf update'
category: puppet
tags: puppet programming
---

[[!meta title=""]]

I've just created a [PR](https://github.com/puppetlabs/puppet/pull/3593)
implmenting the [`scanf`](2015-02-04-puppet-future-parser) function for the
classical parser. Watch it or [the
ticket](https://tickets.puppetlabs.com/browse/PUP-3991) for the merge.
According to [Henrik](https://twitter.com/hel) it should be just in time for
3.7.5 release.

Henrik also pointed me at the nice fact that the future parser will auto-coerce
(fail-safely) strings to numbers in arithmetic expressions. This means `$var +
0` will be either the numerical value of `$var` or a compile error.
