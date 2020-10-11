---
title: "Google Analytics Changes"
category: hosting
tags: web google-analytics
---

For one of the webpages I'm responsible for, I'm tracking traffic through [Google Analytics](https://en.wikipedia.org/wiki/Google_Analytics).
One of the things that really irked me was a massive distortion in the data through traffic that was not very natural to the eye.
Looking for its details found a few posts across the web complaining about similar bot traffic, but no solution that worked for me.
Since the start of September, this traffic has evaporated without me doing anything, and now look much more like I'd expect it.

Here's browser stats from August:

![]({% link assets/2020-10-10-ga-changes/august.png %})

and from September:

![]({% link assets/2020-10-10-ga-changes/september.png %})

On a related topic, I've recently seen folks point out that a lot of browers are switching to auto-blocking google analytics and related cookies, to the point where GA is undercounting traffic by up to 50%.
I don't have a lot of need for user-tracking, but I would like to know general and accurate stats and trends for how specific parts for my webpages are doing.
If you have heard of or experience with a good product that can help with that, I'd be grateful if you clued me in!

Case in point: uBlock Origin originally blocked the screenshots on this post as they were had the words `google-analytics` in the path:

![]({% link assets/2020-10-10-ga-changes/blocked.png %})
