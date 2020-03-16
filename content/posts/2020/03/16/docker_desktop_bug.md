+++ 
draft = true
date = 2020-03-16T16:38:31+08:00
title = "A bug in docker desktop 2.2.0 for Mac OS"
description = ""
slug = "" 
tags = []
categories = []
externalLink = ""
series = []
+++

For Mac OS user, it should be a easy choice that applying Docker Desktop for docker environment setup. However I got a bug with container starting up for port binding, port 111 was in used status by Desktop I thought. It is a bug for Docker Desk 2.2.0. Some user in the community had found it, I think it should be solved in the following version.

https://github.com/docker/compose/issues/7188?fbclid=IwAR0YVaB6Werd_eRETqF0QYu0M9aMoDayILrAuKhP5l3ulGJoVpCSGzQFRG8