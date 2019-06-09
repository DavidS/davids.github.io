---
title: "First Steps with Bolt"
category: puppet
tags: puppet bolt hosting deployment
---

For the longest time (like for the last six(!) years), everytime I pushed a change to my puppet repositories, I would `ssh` and `sudo` onto my puppetmaster and search in my shell history for the commands I used to deploy those changes the last time:

```
david@zion:~$ ssh puppetmaster.example.net -p 2200
Linux puppetmaster 3.2.0-6-amd64 #1 SMP Debian 3.2.102-1 x86_64

The programs included with the Debian GNU/Linux system are free software;
the exact distribution terms for each program are described in the
individual files in /usr/share/doc/*/copyright.

Debian GNU/Linux comes with ABSOLUTELY NO WARRANTY, to the extent
permitted by applicable law.
You have new mail.
Last login: Sat May 25 12:15:46 2019 from example.net
david@puppetmaster:~$ sudo -i
root@puppetmaster:~# cd /srv/puppet/secrets/ && git pull --ff-only && cd /srv/puppet/configuration/ && git pull --ff-only && git submodule update --init --recursive && systemctl restart puppetmaster.service && sleep 1
[...]
```

While totally servicable, I never felt particularily good about having such a crucial step not recorded in some kind of git repo. Today, finally I got with the times and wrapped this up in a task. Here you can see it in action, deploying itself:

```
david@zion:~/git/dasz-configuration$ bolt task run site::puppet_deploy --modulepath ./modules --run-as root -n puppetmaster.example.net:2200
Started on puppetmaster.example.net...
Finished on puppetmaster.example.net:
  Already up-to-date.
  Updating e74a140..d7975aa
  Fast-forward
   modules/site/.gitattributes           |    5 ++
   modules/site/.gitignore               |   27 ++++++++
   modules/site/.pdkignore               |   42 ++++++++++++
   modules/site/.puppet-lint.rc          |    1 +
   modules/site/.rspec                   |    2 +
   modules/site/.rubocop.yml             |  122 +++++++++++++++++++++++++++++++++
   modules/site/.sync.yml                |    5 ++
   modules/site/.travis.yml              |   54 +++++++++++++++
   modules/site/.yardopts                |    1 +
   modules/site/Gemfile                  |   71 +++++++++++++++++++
   modules/site/Modulefile               |    9 ---
   modules/site/Rakefile                 |   76 +++++++++++++++++++-
   modules/site/manifests/init.pp        |   15 ----
   modules/site/spec/default_facts.yml   |    7 ++
   modules/site/spec/spec_helper.rb      |   47 ++++++++++++-
   modules/site/tasks/puppet_deploy.json |    7 ++
   modules/site/tasks/puppet_deploy.sh   |   17 +++++
   17 files changed, 482 insertions(+), 26 deletions(-)
   create mode 100644 modules/site/.gitattributes
   create mode 100644 modules/site/.gitignore
   create mode 100644 modules/site/.pdkignore
   create mode 100644 modules/site/.puppet-lint.rc
   create mode 100644 modules/site/.rspec
   create mode 100644 modules/site/.rubocop.yml
   create mode 100644 modules/site/.sync.yml
   create mode 100644 modules/site/.travis.yml
   create mode 100644 modules/site/.yardopts
   create mode 100644 modules/site/Gemfile
   delete mode 100644 modules/site/Modulefile
   delete mode 100644 modules/site/manifests/init.pp
   create mode 100644 modules/site/spec/default_facts.yml
   create mode 100644 modules/site/tasks/puppet_deploy.json
   create mode 100644 modules/site/tasks/puppet_deploy.sh
  Submodule 'modules/apache' () registered for path 'modules/apache'
  Submodule 'modules/apt' () registered for path 'modules/apt'
  Submodule 'modules/bind' () registered for path 'modules/bind'
  Submodule 'modules/chocolatey' () registered for path 'modules/chocolatey'
  Submodule 'modules/concat' () registered for path 'modules/concat'
  Submodule 'modules/dhcpd' () registered for path 'modules/dhcpd'
  Submodule 'modules/dovecot' () registered for path 'modules/dovecot'
  Submodule 'modules/exim' () registered for path 'modules/exim'
  Submodule 'modules/exiscan' () registered for path 'modules/exiscan'
  Submodule 'modules/firewall' () registered for path 'modules/firewall'
  Submodule 'modules/foreman' () registered for path 'modules/foreman'
  Submodule 'modules/icinga' () registered for path 'modules/icinga'
  Submodule 'modules/inittab' () registered for path 'modules/inittab'
  Submodule 'modules/iptables' () registered for path 'modules/iptables'
  Submodule 'modules/libvirt' () registered for path 'modules/libvirt'
  Submodule 'modules/monitor' () registered for path 'modules/monitor'
  Submodule 'modules/munin' () registered for path 'modules/munin'
  Submodule 'modules/mysql' () registered for path 'modules/mysql'
  Submodule 'modules/nginx' () registered for path 'modules/nginx'
  Submodule 'modules/nrpe' () registered for path 'modules/nrpe'
  Submodule 'modules/ntp' () registered for path 'modules/ntp'
  Submodule 'modules/nullmailer' () registered for path 'modules/nullmailer'
  Submodule 'modules/openssh' () registered for path 'modules/openssh'
  Submodule 'modules/openvpn' () registered for path 'modules/openvpn'
  Submodule 'modules/postgresql' () registered for path 'modules/postgresql'
  Submodule 'modules/puppet' () registered for path 'modules/puppet'
  Submodule 'modules/puppetdb' () registered for path 'modules/puppetdb'
  Submodule 'modules/puppi' () registered for path 'modules/puppi'
  Submodule 'modules/registry' () registered for path 'modules/registry'
  Submodule 'modules/roundcube' () registered for path 'modules/roundcube'
  Submodule 'modules/rsyslog' () registered for path 'modules/rsyslog'
  Submodule 'modules/stdlib' () registered for path 'modules/stdlib'
  Submodule 'modules/sudo' () registered for path 'modules/sudo'
  Submodule 'modules/tftp' () registered for path 'modules/tftp'
  Submodule 'modules/timezone' () registered for path 'modules/timezone'
  Submodule 'modules/vcsrepo' () registered for path 'modules/vcsrepo'
  Submodule 'modules/xinetd' () registered for path 'modules/xinetd'
  Submodule 'vagrant/veewee' () registered for path 'vagrant/veewee'
  {
  }
Successful on 1 node: puppetmaster.example.net:2200
Ran on 1 node in 9.47 seconds
david@zion:~/git/dasz-configuration$
```

See [this commit](https://github.com/DavidS/dasz-configuration/commit/d7975aab3c73710b4609b9a493b7f36ea0af4908) for the rather trivial implementation details.
