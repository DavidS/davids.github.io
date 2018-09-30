---
title: 'Fixing all the Things'
category: puppet
tags: puppet testing retrospec exim
---

> Please note that this post is a linear and unedited brain dump of what I did. Many things might have changed meanwhile, and I may have learned how to do things better. This is an experiment in progress.

This is a continuation of [[yesterday's post|/posts/2016-03-26-bootstrapping-a-module]], refreshing my [exiscan module](https://github.com/DavidS/puppet-exiscan) using [retrospec-puppet](https://github.com/nwops/puppet-retrospec).

# Braindump

To recap from yesterday, I stopped after finally getting all the boilerplate code up and running, so that the new tests told me that the `exim` class was missing. In the current code this was a local version of `example42/exim`. Alessandro has deprecated that module and replaced it with his [example42/tp](https://github.com/example42/puppet-tp) thing that is mostly data driven. This is something I wanted to have a look at for the longest time.

First, I started with changing the `.fixtures.yml` to install the example42/tp module which I wanted to try to for the longest time:

```
fixtures:
    symlinks:
      exiscan: "#{source_dir}"
    forge_modules:
      stdlib: "puppetlabs/stdlib"
      tp: "example42/tp"
```

Installing:

```
david@zion:~/git/davids-exiscan$ bundle exec rake spec_prep
Notice: Preparing to install into /home/david/git/davids-exiscan/spec/fixtures/modules ...
Notice: Downloading from https://forgeapi.puppetlabs.com ...
Notice: Installing -- do not interrupt ...
/home/david/git/davids-exiscan/spec/fixtures/modules
└── puppetlabs-stdlib (v4.11.0)
Notice: Preparing to install into /home/david/git/davids-exiscan/spec/fixtures/modules ...
Notice: Downloading from https://forgeapi.puppetlabs.com ...
Notice: Installing -- do not interrupt ...
/home/david/git/davids-exiscan/spec/fixtures/modules
└── example42-tp (v1.0.0)
david@zion:~/git/davids-exiscan$
```

Looking at the manifest, I will start at one of the leaf classes: `exiscan::spamassassin`, which configures a `spamd` to use with exiscan. It is a very simple package/file/service class, and should lend itself well to getting all gears greased up, for when I start working on the more complex parts. There is no [predefined data blob for tp](https://github.com/example42/tinydata/tree/master/data) so I'll stay with a manual implementation until I have used tp with one of the existing blobs.

# Fixing test failures

The tests were created using puppet-restrospec and puppet 3.7. Since puppet4 is my target, I've changed the Gemfile to default to `puppet ~> 4.0`, which got me 4.4.1. The first easy failure is this:

```
9) exiscan::spamassassin should contain File[/etc/systemd/system/spamassassin.service] with ensure => "present", group => "root", mode => "0644", notify => "Service[spamassassin]", owner => "root", require => "Package[spamassassin]" and source => "puppet:///modules/exiscan/spamassassin/spamassassin.service"
   Failure/Error:
     is_expected.to contain_file('/etc/systemd/system/spamassassin.service')
       .with(
         'ensure'  => 'present',
         'group'   => 'root',
         'mode'    => '0644',
         'notify'  => 'Service[spamassassin]',
         'owner'   => 'root',
         'require' => 'Package[spamassassin]',
         'source'  => 'puppet:///modules/exiscan/spamassassin/spamassassin.service'
       )

     expected that the catalogue would contain File[/etc/systemd/system/spamassassin.service] with mode set to "0644" but it is set to 420
   # ./spec/classes/spamassassin_spec.rb:118:in `block (2 levels) in <top (required)>'
```

This is both easily explained and fixed. Puppet 3 interprets everything as a string. Specifically, a file mode like `0644` is passed through to the implementation as the four characters `'0'`, `'6'`, `'4'`, and `'4'`. Puppet 4 on the other hand, sees the digits and interprets them as a number, and - thanks to the leading zero - reads this as a number in base 8, passing `420` to the `file` type, which would be utterly confused by this. I quote all modes and fix four out of the nine current failures. I also fix all occurrences in the other manifests, so I don't have to think about them later.

## Relationships: It's Complicated

```
5) exiscan::spamassassin should contain File[/var/spool/exim4/scan] with ensure => "directory", group => "clamav", mode => "2750", notify => "Service[exim4]", owner => "Debian-exim" and require => "[Package[$exim::package], Package[clamav-daemon]]"
   Failure/Error:
     is_expected.to contain_file('/var/spool/exim4/scan')
       .with(
         'ensure'  => 'directory',
         'group'   => 'clamav',
         'mode'    => '2750',
         'notify'  => 'Service[exim4]',
         'owner'   => 'Debian-exim',
         'require' => '[Package[$exim::package], Package[clamav-daemon]]'
       )

     expected that the catalogue would contain File[/var/spool/exim4/scan] with require set to "[Package[$exim::package], Package[clamav-daemon]]" but it is set to [:undef, Package[clamav-daemon]{:name=>"clamav-daemon"}]
     Diff:
     @@ -1,2 +1,4 @@
     -[Package[$exim::package], Package[clamav-daemon]]
     +undef
     +
     +Package[clamav-daemon]

   # ./spec/classes/spamassassin_spec.rb:107:in `block (2 levels) in <top (required)>'
```

The reference to `$exim::package` is broken. No surprise there, there is no exim class. The rendered value had [more issues](https://github.com/nwops/retrospec-templates/issues/8). I changed the line in the test to this:

```
'require' => ['Package[exim4-daemon-heavy]', 'Package[clamav-daemon]']
```

as this is the expected package. The error looks much friendlier now:

```
Diff:
@@ -1,4 +1,4 @@
-Package[exim4-daemon-heavy]
+undef

 Package[clamav-daemon]
```

Reconsidering, I add `tp::install{exim:}` to the manifest, and require `Tp::Install[exim]`, instead of the package. Since depending on the tp:install is only an implementation detail, the tests now need to use rspec-puppet's relatively new [support for transitive dependency checks](https://github.com/rodjek/rspec-puppet/#relationship-matchers):

```
it do
  is_expected.to contain_file('/var/spool/exim4/scan')
    .that_requires(['Package[exim4-daemon-heavy]', 'Package[clamav-daemon]'])
    .with(
      'ensure'  => 'directory',
      'group'   => 'clamav',
      'mode'    => '2750',
      'notify'  => 'Service[exim4]',
      'owner'   => 'Debian-exim',
    )
end
```

After adding the required `example42/tinydata` module to the fixtures, the tests worked on first try. Unexpected, but welcome. Two more down, three to go.

## Basic Resources

The next two failures are a mixture of the above errors. The generated tests for multiple packages and resources are not quite right. I replace them with these improved versions:

```
['spamassassin', 'libmail-dkim-perl', 'clamav-daemon', 'libclass-dbi-pg-perl', 'spf-tools-perl'].each do |p|
  it { is_expected.to contain_package(p).with('ensure' => 'installed') }
end
['spamassassin', 'clamav-freshclam', 'clamav-daemon'].each do |s|
  it do
    is_expected.to contain_service(s)
      .that_requires(['spamassassin', 'libmail-dkim-perl', 'clamav-daemon', 'libclass-dbi-pg-perl', 'spf-tools-perl'].collect {|p| "Package[#{p}]" })
      .with(
        'enable'  => 'true',
        'ensure'  => 'running',
    )
  end
end
```

This creates separate examples for each package and service, which helps debugging, when something goes wrong.

The last failure is again a rendering problem, where the content of a file is supplied by a template, which puppet-retrospec (luckily, who wants oodles of config in the test?) did not expand. I just remove the test for content. Checking the service's configuration is best left to the service itself, which will be covered in a [beaker](https://github.com/puppetlabs/beaker-rspec) test later anyways.

```
Finished in 1.67 seconds (files took 0.52661 seconds to load)
16 examples, 0 failures
```

Wohoo!

## Shaping up the Design

Now that the first class is passing tests, I can take a step back to think about the new design. Having `exiscan::spamassassin` install exim is obviously a no-go, as it should not be its concern. For now, I'll claim that the `exiscan::spamassassin` is a private implementation detail and the parent class will have to take care to setup its environment properly. I move the `tp::install` to the main class. This also requires the tests to have that class pre-configured:

```
let(:pre_condition) do
  <<-PP
    class { 'exiscan':
      sa_bayes_sql_dsn => 'place_value_here',
      sa_bayes_sql_username => 'place_value_here',
      greylist_dsn => 'place_value_here',
      greylist_sql_username => 'place_value_here',
    }
  PP
end
```

Of course, this now requires that the main class' tests pass. The first error is, again, dependencies into the exim class, which I replace with `Tp::Install[exim]`.

During fixing the tests, I sent a PR upstream to [improve readability of default error messages](https://github.com/nwops/retrospec-templates/pull/9), and a issue when [rendering values with escapes](https://github.com/nwops/puppet-retrospec/issues/56). Sometimes I think I should go into QA.

---
Random tip: How to find the start of your test run?

```
david@zion:~/git/davids-exiscan$ echo ------------- | figlet; bundle exec rspec -fd -c spec/classes/exiscan_spec.rb ;


 _____ _____ _____ _____ _____ _____ _____ _____ _____ _____ _____ _____ _____
|_____|_____|_____|_____|_____|_____|_____|_____|_____|_____|_____|_____|_____|



exiscan
  should contain Tp::Install[exim] with settings_hash => {"package_name"=>"exim4-daemon-heavy"}
  should contain Class[exiscan::spamassassin] with bayes_sql_dsn => "sa_bayes_sql_dsn_value", bayes_sql_password => "s3cr3t", bayes_sql_username => "sa_bayes_sql_username_value" and trusted_networks => "10.0.0.1"
[...]
```
---

Another interesting test was something that required a optional parameter set to a non-default value. The generated test was

```
it do
  is_expected.to contain_class('exiscan::spamassassin_db')
    .with(
      'db_password' => '',
      'db_username' => ''
    )
end
```

The improved tests looks like this, and test for both cases of `sa_bayes_sql_local`:

```
context 'without a local sa_bayes_sql' do
  # sa_bayes_sql_local = false is default
  it do
    is_expected.not_to contain_class('exiscan::spamassassin_db')
  end
end

context 'with a local sa_bayes_sql' do
  let(:params) do
    super().merge({
      sa_bayes_sql_local: true
    })
  end
  it do
    is_expected.to contain_class('exiscan::spamassassin_db')
      .with(
        'db_password' => '',
        'db_username' => ''
      )
  end
end
```

## More Dependencies

After removing some of the more syntactical issues, it turns out that I've converted many dependency chains from `Package[exim] -> something local ~> Service[exim]` to loops, as `Tp::Install[exim]` contains `Service[exim]`. Even worse, it is not really called `exim` anymore, because that name is dependent on the underlying OS and when I added in the proper OS facts (used elsewhere) everything blew up even harder.

To get a stable base for such dependencies, I've [enabled tp to provide stable names](https://github.com/example42/puppet-tp/pull/17) for the main package and service resources.

The main class no tests fine, but it directly includes the `exiscan::spamassassin` so all the tests for that class fail on duplicate resource for the two class declarations (exiscan's and the test's). To keep the tests, I move them into the main `exiscan_spec.rb` and adapt the to fit. Amongst other things that meant restoring the `Package[exim]` dependencies and tests.

I've also added the compile test to all contexts that had non-default params set:

```
it { is_expected.to compile.with_all_deps }
```

With "good" results:

```
1) exiscan with a local sa_bayes db should compile into a catalogue without dependency cycles
   Failure/Error: it { is_expected.to compile.with_all_deps }
     error during compilation: Evaluation Error: Error while evaluating a Resource Statement, Evaluation Error: Error while evaluating a Resource Statement, Invalid resource type concat at /home/david/git/davids-exiscan/spec/fixtures/modules/postgresql/manifests/hbaconcat.pp:7:3 at /home/david/git/davids-exiscan/spec/fixtures/modules/postgresql/manifests/dbcreate.pp:38 on node zion.black.co.at
   # ./spec/classes/exiscan_spec.rb:114:in `block (3 levels) in <top (required)>'
```

Turned out that my concat fixture was broken. Re-downloading fixed it. Revealing a more pertinent error:

```
1) exiscan with a local sa_bayes db should compile into a catalogue without dependency cycles
   Failure/Error: it { is_expected.to compile.with_all_deps }
     error during compilation: Parameter mode failed on File[spamassassin_3_2_2_initial.sql]: The file mode specification must be a string, not 'Fixnum' at /home/david/git/davids-exiscan/spec/fixtures/modules/exiscan/manifests/spamassassin_db.pp:23
   # ./spec/classes/exiscan_spec.rb:114:in `block (3 levels) in <top (required)>'
```

File mode, my old nemesis!

## Misc Last Words

Another small improvement to the templates, [adding the default compile test](https://github.com/nwops/retrospec-templates/pull/10).

So finally the spec tests for the main class pass. The `*_db_spec` were generated empty, so I need to have a look at them too. Puppet-lint is also complaining massively about my last-year style. And finally, all of these efforts are for naught, if the module doesn't actually configure exim properly, which needs to be validated on a running system. Luckily, tomorrow is another day off!
