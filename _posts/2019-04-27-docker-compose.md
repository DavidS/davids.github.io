---
title: "Docker Compose for OwnCloud"
category: hosting
tags: docker docker-compose owncloud hosting
---

I'm running a private owncloud server - because, why wouldn't I? To get rid of my old KVM=based virtualisation solution, I've recently switched to [docker-compose](https://docs.docker.com/compose/) - "a tool for defining and running multi-container Docker applications".

While in general docker-compose is really nice to work with, and can get you quick wins, this post will detail a few of the day 2 pitfalls and the solutions I found.

# Shutting down the service

If, for whatever reason, you want to have the services _not_ running `docker-compose down` is your go-to command. Do not get (overly) scared by the synopsis of the command removing "containers, networks, volumes, and images". While it _can_ do that, by default it only removes running state, that is containers, and networks, but leaves persistent state like volumes and images alone.

# Updating the containers

After ascertaining that a `down` does not nuke away all my data, I tried updating the containers using the default turn-off-turn-on cycle. I also tried to use the `--foce-rebuild` command line option. Although *something* was happening, it turned out that no new upstream container images where retrieved.

There is a separate `docker-compose pull` command to do so:

```
~/owncloudserver # docker-compose pull
Pulling db       ... done
Pulling redis    ... done
Pulling owncloud ... done
~/owncloudserver #
```

After this, a restart of the service will start the new containers based on the new images. Of course by "restart", I mean

```
~/owncloudserver # docker-compose down
Stopping owncloudserver_owncloud_1 ... done
Stopping owncloudserver_db_1       ... done
Stopping owncloudserver_redis_1    ... done
Removing owncloudserver_owncloud_1 ... done
Removing owncloudserver_db_1       ... done
Removing owncloudserver_redis_1    ... done
Removing network owncloudserver_default
~/owncloudserver # docker-compose up
Creating network "owncloudserver_default" with the default driver
Creating owncloudserver_db_1    ... done
Creating owncloudserver_redis_1 ... done
Creating owncloudserver_owncloud_1 ... done
~/owncloudserver #
```

# Protecting the network

The owncloud compose file exports a single port to access the webserver. I'm proxying this port through the host's nginx for SSL termination. Sadly enough, docker-compose seems to know only internal ports (defined as `expose:` in the YAML) which are only accessible from other containers) and external ports (defined as `ports:` in the YAML) which are accessible from _everywhere_. See this [stackoverflow answer](https://stackoverflow.com/a/40801773/4918) for details.

> I really "appreciate" the subtle trap of having the _exposed_ ports being protected, while the regular _ports_ are globally exposed.

To make sure that the unencrypted port is not used, I should add a firewall rule to deny access from outside. Watch this space to see my cry about having forgotten that rule in a year's time, when I don't understand why something is not working.

I probably should also add something like [HSTS](https://en.wikipedia.org/wiki/HTTP_Strict_Transport_Security) to make sure that no redirect escapes from the underlying owncloud and induces someone to send their username/password in the clear. More fun.

# "Random" redirects

For some reason the owncloud instance would redirect some requests to it's internal port (8080, see above), which would cause all sorts of problems. I played around with quite a few things, but the only thing that stuck was adding hardcoded redirect rules into the nginx proxy itself to avoid that problem from reaching owncloud:

```
rewrite /.well-known/caldav https://oc.black.co.at/remote.php/dav;
rewrite /.well-known/carddav https://oc.black.co.at/remote.php/dav;
```

# Random notes

## container content conundrum

It's very weird to me how the containers have kernel-related tools like `/sbin/installkernel` and filesystem utilities like `/sbin/badblocks` both of which I can't find a use for in a container, but is lacking network tools like `ip` which could be helpful in understanding the container's configuration from the inside.
