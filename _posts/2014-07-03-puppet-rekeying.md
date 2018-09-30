---
title: 'Puppet Rekeying'
tags: puppet foreman puppetdb ssl security
---

# Problems with puppet CAs

If you have created your puppet ca in The Good Old Days[tm], the chances are
big that you're still vulnerable to an impersonation attack, where an attacker
on one of your nodes tricks the puppet master to sign off on a certificate that
has the same CN as the CA. You can check you CA CN with this command:

    openssl x509 -noout -text -in $(puppet master --configprint cacert)

The `Subject` field must start with `CN=Puppet CA:` to avoid collisions with
the simple `CN=fqdn` subjects of node certificates.

If you have your CA already this long, then you'll soon notice the `Certificate
'puppetmaster.example.com' will expire on 2014-07-22` message on your agent
runs.

Finally, if you're running your puppetmaster as a publically accessible
service, e.g. because you're serving a dynamic, heterogeneous, global set of
nodes, you might very well be exposed to [Heartbleed](http://heartbleed.com/).
Which has potentially compromised all your certificates anyways.

# Simple Solution

In the simplest case you really only want to redo the CA certificate, without
changing the CN, the key or anything else, except the "valid until" date.
Move the `$cacert` file to a save place and run `puppet cert list` to
regenerate it with a current certificate. You can check differences by
comparing both `openssl x509` outputs (see above) for both certificates. They
should have the same `Subject` and `Subject Public Key Info` values, but the
new certificate has a fresh `Validity` period, by default five years into the
future.

Deploy the new file to `$localcacert` on all nodes and you're set.

The great thing is that nodes with the old CA cert will still correctly
validate all connections as the `Subject` of the new cert matches what's
written on all certificates.

# Further complications

If your situation is not so simple, I have a few more tricks saved for the next
installment.

# Other puppet CA users

When futzing around with puppet certificates, you always have to remember other
places where you have reused those certificates. In my case this was
[foreman](http://theforeman.org) and
[puppetdb](http://docs.puppetlabs.com/puppetdb/). Both cause grief when not
handled.

## puppetdb

Depending on the specific setup and version, puppetdb either has its own local
truststores which have to be refreshed or accesses the puppet certificates
directly in `$ssldir`.

Before proceeding, make a backup of `/etc/puppetdb`.

In the former case, run `puppetdb-ssl-setup -f` and restart puppetdb. In the
latter case, just restart it.

Do not forget that puppetdb can take more than ten seconds before it is ready
to accept API calls. Watch the logfile (`tail -F /var/log/puppetdb/*log`) to be
notified of the actual resumption of service:

    2014-07-03 23:41:48,008 INFO  [o.e.j.s.ServerConnector] Started ServerConnector@123456ab{SSL-HTTP/1.1}{puppetmaster.example.com:8081}
    2014-07-03 23:41:48,054 INFO  [c.p.p.c.services] PuppetDB version 2.0.0
    2014-07-03 23:41:48,190 INFO  [c.p.p.c.services] Starting broker
    2014-07-03 23:41:49,225 WARN  [o.a.a.b.BrokerService] Store limit is 100000 mb, whilst the data directory: /var/lib/puppetdb/mq/localhost/KahaDB only has 9714 mb of usable space
    2014-07-03 23:41:49,225 ERROR [o.a.a.b.BrokerService] Temporary Store limit is 50000 mb, whilst the temporary data directory: /var/lib/puppetdb/mq/localhost/tmp_storage only has 9714 mb of usable space
    2014-07-03 23:41:49,225 INFO  [c.p.p.c.services] Starting 2 command processor threads
    2014-07-03 23:41:49,240 INFO  [c.p.p.c.services] Starting query server
    2014-07-03 23:41:49,243 WARN  [o.e.j.s.h.ContextHandler] Empty contextPath
    2014-07-03 23:41:49,253 INFO  [o.e.j.s.h.ContextHandler] Started o.e.j.s.h.ContextHandler@123456ab{/,null,AVAILABLE}
    2014-07-03 23:41:49,288 INFO  [c.p.p.c.services] Starting sweep of stale reports (threshold: 14 days)
    2014-07-03 23:41:49,336 INFO  [c.p.p.c.services] Finished sweep of stale reports (threshold: 14 days)
    2014-07-03 23:41:49,337 INFO  [c.p.p.c.services] Starting database garbage collection
    2014-07-03 23:41:49,382 INFO  [c.p.p.c.services] Finished database garbage collection

## foreman

My foreman is configured to run in passenger in apache using the puppet
certificate and key directly from `$ssldir`. Restarting the apache loaded the
new CA PEM file just fine. After this `node.rb` worked again.
