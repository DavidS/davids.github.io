---
title: "Application lifecycle (with containers)"
category: devops
tags: devops hosting deployment applications containers docker docker-compose
---

A few days ago, I posted a random thought on twitter. I got surprisingly positive feedback, and some thoughtful conversations about details. This post is a follow-up where I'm expanding on this.
<!-- TODO: link -->.

Currently with docker-compose, my implementation for these is as follows:

* Install: locate a compose yaml, clone or init a git repo with the file and surrounding scripts to your host.
* Configure: analyse the compose file and used docker images to identify the injection points (usually environment variables) and set the desired values in te `.env` file.
* Publish: `docker-compose up -d`, except that you need some custom nginx configuration to hook it up to your frontend nginx and there are 100 ways this could go wrong. Don't get me started on SSL termination and authentication proxying.
* Backup: `/var/lib/docker/volumes` contains neatly named directories with all data of your application. Except for those images that were using internal volumes, which do not have a name, and instead are just a large hex string. Oh, and of course except all your database images, because backing up the binary files doesn't mean that you can restore from it, because who knows in what state the DB is while you're copying it away. So I'm just making a copy of those files and hope for the best.
* Restore: See above, but with more fingers crossed when copying the files back.
* Inspect: `docker ps` shows me running configs. By god, I hope I remember where I put the `docker-compose.yml`. This is less of an issue on my production host, since there I've got everything in `/root` (I was young and needed the money), but on my dev workstation I've already found an abandoned project running in the background wasting a CPU core, where I'm pretty sure the compose file and directory already had been deleted.
* Update: See [my previous post](/log/posts/2019-04-27-docker-compose/) on the topic. It is not very transparent to me. I just hope that new versions of the containers can deal with existing data versions and run upgrade migrations as required. It also requires updating the compose and config to deal with whatever changes happened upstream since the last update. There are no notifications that something needs to be updated.
* Patch: Sometimes, you need "just this one patch". with compose files, you can easily switch up an image for a locally built version that comes from a `Dockerfile` specifying `FROM "original"`. Such images get automatically built on deploy, if required.
* Migrate: Luckily, I haven't required that yet, but with volumes and config being nicely separated, I hope that'll be rather straight-forward.
* Decommission: `docker-compoes kill` the running processes. Then there is some incantation to also get rid of the volumes. Then I can clean up/remove the config directory. Not awful as a process, but easy to forget a step. Don't ask me how I know O:-)

While this process is _basically_ working, it is tedious, error-prone, full of one-offs and workarounds, requires understanding the diverse individual image's workings to wire everything together. Only some projects provide working compose files, and some docker images are unexpectedly unwieldy to use and/or contain bugs that make configuring them hard. Especially mapping applications into my public webserver is a world of pain, since existing compose files usually assume _no_ shared frontend server and bring their own frontend webserver. While I understand the motivation behind it (providing a one-stop deployment solution), the consequences are that SSL termination and co-hosting of multiple apps is incredibly frustrating.

I'm currently working as root on my production host because I didn't know better at the start. Later I also realised that even when running as non-root, the containers still run processes with whatever uid was baked into the image, and the volumes, will expose files using those uids. For local development this is quite inconvenient. For production use this is seems risky, as having a user on the host means that it is easy to accidentally gain access to some files from a running container. Currently I work around this by not granting anyone but me access on the host.

# Scope Creep

A lot of the confusion and complexity described above is because app developers want their images to be the be-all-end-all for everyone, while not really having the bandwidth to actually solve the problems that would need solving to make that happen. Instead issues are either haphazardly addressed by individuals covering their particular special case, or hoisted on the end-users by providing working but unusable example configurations.

Some thoughts on how this situation could be better. The only way I found working to make a project tractable for me is to radically reduce scope. The only projects I've been successful at were the ones where I was my own customer zero. The scope I'm choosing therefore is "artisanal web application self-hosting". Let me expand on this:

* low traffic / no scaling requirements
* single hobbyist/part-time admin
* single node / no distributed system
* a handful of applications
* "flexible" availability requirements
* more time than money

This covers a lot of folks I've met over the years, from small sites like my own vanity domain hosting this blog to clubs and NGOs who are hosted by volunteers with little or no resources for SaaS offerings.

# Vision

* Install: Like apt, yum or brew, but for compositions. I can query a directory for applications. After selecting an application, the tooling downloads the bits for me. From the directory I can understand who is responsible for the packaging, and where I can contribute changes.
* Configure: From the applications selected, I can create independent instances each with its own private configuration. The configuration file format is easy to write, and the schema easily maps to upstream's documentation. There are common basic configuration directives for repeating information that I can learn once and use often.
* Publish: I define a single route to expose an application at a specific point in my public web namespace (domain names and paths). I can manage my SSL certs in a single place and all applications pick up that they're protected.
* Backup: There is a single command to create a consistent backup for an application. The backup contains, configuration, and all metadata required to fully recover the application as it is running just now.
* Restore: Given a backup from the previous step, I can restore the application to exactly that state on a completely new host.
* Inspect: There is a list of running instances that can be queried. For each instance I can see the current service, diagnostic and access logs. The current configuration is accessible, and I can inspect historical changes to remind me of what I did last summer. I can see which applications are out of date with respect to upstream versions, and which have security issues that I need to address. The tooling knows about all bits on disk and in memory relating to an application instance: Configuration, runtime bits, keys, volumes, backups.
* Update: When I have to install a security update, or want to consume a new feature from upstream, I can run a single command to update a running instance to the newer version.
* Patch: Sometimes I need just that one change to the base-image of something. I can side-load a changed image into the tooling to carry that forward until the change has made it through upstream.
* Migrate: Since Backup/Restore works, I can move the backup to a new machine, restore there and be up-and-running as fast as I can transfer the file.
* Decommision: Since the tooling has working knowledge of all the bits making up an instance, I can delete those bits as necessary when shutting down a service.

# Non-functional Requirements

* Security: It's easy to throw up a few containers and have them run wordpress. It's less straight-forward to do so with the confidence that
  * your mysqld is not listening on a globally accessible port with default credentials,
  * your private gallery is not accessible to that rogue script in cousin Ted's hacked up instance, and
  * you're not unintentionally leaking unencrypted BasicAuth credentials through a confused redirect to port 80. Don't ask me how I know :-(

* Resource usage: the applications will run on a single node that usually is resource constrained and overcommitted. To make this viable, there should be a minimal number of processes running to make the applications tick. For example, there should be one front-end webserver for routing and SSL termination, and one php-fpm instance per PHP application, instead of multiple apaches running that load PHP as cgi-bin.

  Instances also need to be conscientious with their on-disk footprint: use shared base-images, collapse intermediate build layers, strip unused files, keep logfiles under control.


# Why and how I think this could be successful

Like I insinuate in the original tweet, I don't believe that the problems listed above can be fixed at the image or compose level of individual projects. Looking at the solutions our problems of the 90's, like autoconf/automake, Debian, debhelper, I can extrapolate some properties of successful solutions to this for the future:

* usable by mere mortals. autoconf/automake is absolute balls if you ever need to look under the hood, but developers don't need to. Day-to-day usage is cargo-culting a few dependency statements in your config, and running `./configure`. This leads to my next point:
* uniformity. providing a standardised interface buffers the day-to-day users from the nasty under-belly of hacks and work-arounds. See how `dh` has benefitted over the years from building on top of a common stable interface and has risen in popularity for many of the same reasons.
* approachable. while autoconf is a cess-pool of M4 under the hood, that doesn't mean you can't `grep` for the thing you're staring at and bang on it in the source with a big hammer for a while to get it to do what you need. Similarily for debhelper: as a complete system, its million little helpers seem to be a mess, but adding one or modifying an existing one is a tractable task. This is crucial for growing the pool of contributors, and evolving its capabilities moving forward.
* community around open source. Paying for optimizing the common case by making a back-end work more complicated is a win in my eyes. To reap those fruits there need to be users though.
* content content content. automake/autoconf were big improvement over the contemporal experience of building software. So much that within a few years enough people felt that it was less painful to add it to the project they were building than to carry on as they were. A broad base of projects using it in turn meant that any core improvement amortised over tens of thousands of developers and millions of users. Compare this to other build systems like cmake, which did not provide such a huge step forward, did not see an aggressive push to convert everything, and never gained the same universal adoption.
