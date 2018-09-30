---
title: 'Migrating Puppets'
category: puppet
tags: puppet ops
---

I've wrapped up a nice little project preparing an infrastructure to switch to puppet. The customer's own puppet lead had the system configuration already well prepared, so it was mostly a matter of integrating the final pieces, lining up all stars and keeping an eye out for unforeseen surprises.

Some takeaways:

* preparation is everything: having base services like sssd and logstash well tested before starting the switchover was a great help to focus on the more delicate applications.
* reusing puppet's CA for apps is convenient, but creates a noticeable coupling. While it reduces time to rollout, it makes some transitions very troublesome as different parts of the systems use different trusts for prolonged periods while migrating nodes. Having a separate CA would keep those two transitions independent and probably make a cert switchover without longer delays possible. I've still found no obvious way to do good CA handling. The puppet ca face is (understandably) inflexible, and the openssl tinyca scripts are a pain to configure due to openssl's general arcaneness.
* doing base system configuration separately before application deployment makes for a stable base to work off for the latter. Except when it doesn't. For example dynamically excluding data directories from various scanners (aide, AV, locate) is an important point to reconsider for future projects. Having default locations like /srv excluded statically might reduce friction before capturing a complete system. Technically this can be done by using --tags to apply common resources.
* Having no monitoring in place makes for some guesswork as how the changes are impacting the applications. Of course, being in the process of rolling out puppet, this is also an inventory project, making proper monitoring a consequence, not a precondition. Improved tooling could support a process and/or service level inventory/monitoring. Alessandro's puppi/monitoring integration is already going in that direction, but fall short on giving a global view whether everything is caught.
* when doing bigger numbers of changes with puppet it'd be great to be able to define a baseline of acceptable changes. This would make it easier when going from node to node to spot the relevant differences. Normally I'd say testing should have found all those special cases already, but when activating puppet the first time on existing systems, there cannot be - by definition - an accurate test environment and all cases are special cases. Having a way to filter or even selectively apply the common/accepted/checked changes would be helpful. Primarily we solved this by applying the base config separately as described above.

A simple way to do so is collecting all puppet agent logs and checking for non-universal log entries:

    time puppet agent --test --noop --color=false 2>&1 | tee puppet-pre-release-$(date --iso)-$(hostname).log
    sort puppet-pre-release-2014-09-30-* | uniq -c | sort -n | grep "^ *$(ls puppet-pre-release-2014-09-30-*|wc -l) " | sed -e 's/^ *//' | cut -d' ' -f 2- > common_patterns
    grep -vFf common_patterns puppet-pre-release-2014-09-30-* | less

* there were only around ten nodes in this environment, so a central reporting server was not necessary. It might help though, if there are more nodes to migrate.
* always keep an eye on the logs. Two nodes formed a postgres failover cluster managed by redhat's cluster manager. In addition to the complexity of keeping the puppet module from touching the service, the cgmanager is regularly checking the service health. A fact only learned when it started shutting down the pgsqld when it failed to connect to it because the configuration file and SSL config (see above) changed.
* keep all logs together. In the cgmanager incident the postgres log immediately indicated the shutdown, but the cgmanager's log went somewhere else, so diagnosing the root cause proved to be a little more involved due to the fact that nobody thought about checking the "other" log.
* good backups are necessary, but not sufficient. Additional information to keep for reference include the active networking config, iptables rules, process lists, routing table, sysctls. Basically everything that can be changed manually and is not persisted into the filesystem. Some of those also can be a pain if the current state is not recreated properly on a reboot.
