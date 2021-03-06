---
title: 'Migrating to puppet future parser'
category: puppet
tags: puppet
---

The [future
parser](https://docs.puppetlabs.com/puppet/latest/reference/experiments_future.html)
in [puppet](https://puppetlabs.com/) is the compatibility shim to use before
moving to Puppet 4.0, whose release is imminent. The future parser in 3.7
allows us to run the stable version with the parser of the new version, making
manifests and modules ready for a seamless upgrade. Here I'll describe the
steps I needded to make this move.

# Goal

To make the transition possible and easy, I've two goals. first, I want to make
sure that I change as little as possible. This avoids trying too much in a
single pass of the codebase, which helps general stability. Secondly, the code
needs to run on both the old and the new parser to avoid having a flag day
across all people using the example42 modules.

# Preparation

First I've upgraded to the most recent stable puppet version (3.7.4). This
ensure that I have a up-to-date iteration of the future parser, and I'm
developing against the state of the art.

Then I've created a new puppet.conf to use while testing. This way I can leave
the rest of my system running without impact while hacking on the future
branch. More sensible people would use vagrant, but being my own
biggest customer in this prod environment makes things easier.

    --- /etc/puppet/puppet.conf 2015-02-04 12:45:02.000000000 +0100
    +++ /etc/puppet/future.conf 2015-02-04 12:45:16.000000000 +0100
    @@ -32,21 +32,17 @@
       listen = false
       runinterval = 1800
       localconfig = $vardir/localconfig
    -  environment = production
    +  environment = future
    +  masterport = 8888
    +  noop = true

     [master]
       bindaddress = 0.0.0.0
       autosign = false

    -  environment = production
    -  manifest    = /srv/puppet/configuration/manifests/site.pp
    -  modulepath  = /srv/puppet/configuration/modules
    -  manifestdir=/srv/puppet/configuration/manifests
    +  masterport = 8888
    +  pidfile = /var/run/puppet/future.pid
    +  parser = future
    +  environment = future
    +  environmentpath = /srv/puppet/environments

Commands:

    puppet master --no-daemonize --verbose --config=/etc/puppet/future.conf
    puppet agent --test --config=/etc/puppet/future.conf --noop


I hadn't enabled [directory
environments](https://docs.puppetlabs.com/puppet/latest/reference/environments_configuring.html)
and [manifest
directory](https://docs.puppetlabs.com/puppet/latest/reference/dirs_manifest.html#directory-behavior-vs-single-file),
so you see that there too. They are required to get access to a more nuanced
deployment workflow, caching and getting rid of "import", which helps the
autoloader to actually notice that things have changed.


# Puppet changes

After those preparations, puppet now can tell me what I'm doing wrong, let's get to the various things to fix:

  * `Error: This 'if' statement is not productive. A non productive construct may only be placed last in a block/sequence`
  * `Error: Evaluation Error: Use of 'import' has been discontinued in favor of a manifest directory.`

  * `Error: Evaluation Error: No matching entry for selector parameter with value '6'`: this one is nasty. Here's the code:

        # Cope with Debian's folies
        $debian_isc_era = $::operatingsystem ? {
          /(?i:Ubuntu)/ => $::lsbmajdistrelease ? {
            8       => '5',
            9       => '5',
            default => '6',
          },
          /(?i:Debian)/ => $::lsbmajdistrelease ? {
            5       => '5',
            default => '6',
          },
          default   => '6',
        }

        ### Application related parameters

        $package = $::operatingsystem ? {
          /(?i:Debian|Ubuntu|Mint)/ => $debian_isc_era ? {
            5 => 'dhcp3-server',
            6 => 'isc-dhcp-server',   # <<<<<  Error HERE
          },
          /(?i:SLES|OpenSuSE)/      => 'dhcp-server',
          default                   => 'dhcp',
        }

    The error is flagged on the marked line with "Error HERE", luckily, because
    this selector has no default case. What happens, is that facter delivers
    `$::lsbmajdistrelease` as a string and the `? { 5 =>` is not matching `"5"`
    as it is a different type. The first selectors all have default statements
    that fall through to the default label due to the mismatch.

    The recommended solution is to use `scanf` to type-convert safely.

# Intermission

Using `scanf` brings several problems. First, it is only available in the
future parser. Secondly, there is no good way to find all instances where the
stricter interpretation will cause mismatches.

To actually prepare for a safe and regression-free migration, I've also
upgraded travis files to actually test against the future parser.

Or, at least, tried to. The module I was working on proved to be of the older
sort and testing [@garethr](https://twitter.com/garethr)'s
[puppet-module-skeleton](https://github.com/garethr/puppet-module-skeleton)
[didn't really work
out](https://travis-ci.org/DavidS/puppet-scanf/builds/49461609) either.


# Acknowledgements

This post was written at the [Puppet Contributor Summit Gent
2015](http://cfgmgmtcamp.eu/puppet.html), graciously sponsored by Puppetlabs.
