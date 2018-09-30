---
title: 'Puppet Tricks - static resource dispatch'
tags: puppet programming devops
---

## Static Resource Dispatch

Something I've already used to good effect is putting data for `create_resources`
into hiera to configure customer stuff. My prime example is this [hosting
module](https://github.com/DavidS/dasz-configuration/blob/master/modules/hosting/).
On the host where tihs is running, I'm [loading the data from a YAML
file](https://github.com/DavidS/dasz-configuration/blob/master/manifests/nodes/hosting3.edv-bus.at.pp#L30)
and pass it on the the [customer
define](https://github.com/DavidS/dasz-configuration/blob/master/modules/hosting/manifests/customer.pp).
This allows me to configure a customer's domains, databasesr, P.O. boxes and
other stuff from a private yaml like this:

    ---
    customers:
      dasz:
        type: owner
        admin_user: david-dasz
        admin_fullname: "David Schmitt"
        db_password: geheim1
        domains:
          dasz.at:
            serial: 2014021900
            additional_rrs:
              - "office.dasz.at.  A 88.198.141.234"
        users:
          david-dasz:
            comment: David Schmitt
        mysql_databases:
          dasz_wordpress:
            password: geheim1
        pg_databases:
          dasz_owncloud:
            password: geheim1

This way I can keep the private data private while still publishing my modules
on github without remorse.

## Dynamic Resource Dispatch

One thing that bugged me about the above setup is that the
[hosting::customer](https://github.com/DavidS/dasz-configuration/blob/master/modules/hosting/manifests/customer.pp)
is a bit verbose in checking for hash-ness and passing the right type name to
create\_resources. To rectify this, I've had this idea of doing a dynamic
dispatch resource, that takes the data from yaml and builds resources without
having to repeat boilerplate code.


    $data = {
      'file' => {
        'args' => {
          '/home/david/tmp' => {
            'ensure' => 'directory'
          },
          '/home/david/tmp2' => {
            'ensure' => 'directory'
          },
        },
      },
      'notify' => {
        'args' => {
          'msg1' => {
            'message' => 'hello'
          },
          'msg2' => {
            'message' => 'world'
          },
        },
      },
    }

    create_resources('drd', $data)

    define drd($args) {
      if (is_hash($args)) {
        create_resources($name, $args)
      }
    }


This is just a sketch how this could work. The `drd` define will transform any
data from the hash into proper resources. This currently has a few downsides:

  * the additional `$args` level required
  * there can only be one `Drd[file]` in the catalog

On the positive side, you can have a `drd` for each use-case you're having and
add customization like a little transformation to the type name to clean up the
input data:

  define hosting::drd($args) {
    create_resources("hosting::${name}", $args)
  }

## Automatic Password Rollover

The final one really demonstrates the power of automation. At a client's site
the current enterprise security rat race is ensuring that all app's database
passwords are rotated once a year. While most databases in our group are
[PostgreSQL](http://www.postgresql.org/) where the apps are authenticaed on the
Unix socket and therefore do not need a password (yay!),
[PuppetDB](https://docs.puppetlabs.com/puppetdb/) is only able to use
[TCP](https://twitter.com/dev_el_ops/status/557193105502654464) to connect to
its database. Using the `cache_data` and `random_password` functions from
[foreman's puppet
module](https://github.com/theforeman/puppet-foreman/tree/master/lib/puppet/parser/functions)
and `stdlib`'s strftime, the following call will create a password that changes
once a week:

    cache_data(strftime('puppetdb_%Y_%W'), random_password(32))

Using this, the puppetdb database now gets a new password every monday morning
and the Information Protection Officer is officially "Happiest Person Of The
Day". Problem solved!
