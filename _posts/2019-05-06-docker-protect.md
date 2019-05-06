---
title: "Simple Docker Compose Protection"
category: hosting
tags: docker docker-compose hosting security
---

A follow-up to [last week's docker-compose post](/log/posts/2019-04-27-docker-compose/).

# Updating the containers

Contrary to my assertion last week, `docker-compose up` happily restarts service containers:

```
~/owncloudserver # docker-compose up -d
Recreating owncloudserver_db_1    ... done
Recreating owncloudserver_redis_1 ... done
Recreating owncloudserver_owncloud_1 ... done
~/owncloudserver # git show
```

Because, of course, why wouldn't it?

# Protecting the network

[lskillen](https://nitech.slack.com/team/U94ASMRL7) from the [NI Tech Slack](https://nitech.slack.com) pointed out that I can also specify a IP address in the compose file:

```
diff --git a/docker-compose.yml b/docker-compose.yml
index ffbd51b..dd5d8a8 100644
--- a/docker-compose.yml
+++ b/docker-compose.yml
@@ -15,7 +15,7 @@ services:
     image: owncloud/server:${OWNCLOUD_VERSION}
     restart: always
     ports:
-      - ${HTTP_PORT}:8080
+      - "127.0.0.1:${HTTP_PORT}:8080"
     depends_on:
       - db
       - redis
```

Now the unencrypted backend port is not accessible from the outside anymore, and I didn't have to fiddle around with firewall rules.

```
~/owncloudserver # netstat -ant
Active Internet connections (servers and established)
Proto Recv-Q Send-Q Local Address           Foreign Address         State
[...]
tcp        0      0 127.0.0.1:8080          0.0.0.0:*               LISTEN
[...]
```
