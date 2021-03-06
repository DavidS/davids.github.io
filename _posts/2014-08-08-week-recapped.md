---
title: 'week recapped'
tags: puppet ops osm hosting owncloud
---

# This week's summary

Spent much time at customer's so not much time for real-time updates. Here's a
short summary.

  * [opentsdb-collectd-writer](https://github.com/DavidS/opentsdb-collectd-writer):
    write to [opentsdb](http://opentsdb.net/) from
    [collectd](https://collectd.org/).
  * I've also created a [Grafana](http://grafana.org/) dashboard for this
    metric scheme, but that is quite limited as it cannot filter by tags, so
    there's some work left on the presentability front.
  * Upgraded to [owncloud
    7](https://owncloud.org/blog/owncloud-7-released-with-more-sharing-and-control/)
    and 7.0.1. It still works. Server-to-server sharing is nice too, but falls
    on it's face with a share of 1300 files. Also found the owncloud command line.
    Now I can ([almost](https://github.com/owncloud/core/issues/9891)) convert
    between databases, and when starting the upgrade from the commandline, no
    feedback is given. When this is aborted (due to ignorance) the update
    cannot be restarted (easily) since it unconditionally tries to drop tables.
  * Finally, I've put in some hours for the [Humanitarian Openstreetmap Team's
    Activation around the Ebola outbreak in
    Africa](http://www.hotosm.org/updates/2014-08-05_reactivation_of_hot_for_the_ebola_epidemic_second_update).
    You can help too!
