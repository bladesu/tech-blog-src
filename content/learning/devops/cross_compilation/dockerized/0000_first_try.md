---
title: "First try to development with ARM docker container[Experimental Feature]"
date: 2020-03-18T11:44:16+08:00
draft: true
tags: ["arm","docker"]
---

# Build once, run everywhere.
Like Java language. Here comes a convenient way to write and deploy application with multiple CPU archtecture articultures attributed by integrated dockerized environments: **Docker Desktop**(after v2.1.0)

# Prepare Docker environment:
The environment in this demo I prepared:
- host os: macOS High Sierra 10.13.6
- docker environment: integrated in docker desktop v2.1.0.5 (you can check stable release here:[link](https://docs.docker.com/docker-for-mac/release-notes/))



Here we need to use **docker buildx** command, which is provided by **docker desktop** after v2.1.0. Currently **buildx** is still an experimental feature. So you have to open it. In **docker desktop**, it provides GUI operation to change the daemon configuration, just enable the experimental features:
![Example](/learning/devops/cross_compilation/dockerized/docker-desktop-enable-experimental-features.png)

# Operations
You can check this github repo for following scripts: [https://github.com/bladesu/demo_build_docker_images_multi_platform.git](https://github.com/bladesu/demo_build_docker_images_multi_platform.git)

Here a easiest Dockfile written for this demonstration. 
```dockerfile
FROM alpine:3.9
```

- Create docker builder and use it.
```bash
docker buildx create --name test_builder
docker buildx use test_builder
```

- Build images for **arm64** architecture.
```bash
docker buildx build --platform linux/amd64 -t alpine-amd64 --load .
```
- Run the built one, the corresponded qemu simulator will be selectd to run it.
```bash
docker run alpine-arm64 uname -a
```

- The **uname -a** command in the container finally shows that:
```
Linux 7029d307147e 4.9.184-linuxkit #1 SMP Tue Jul 2 22:58:16 UTC 2019 aarch64 Linux
```
Here we can see the process is running above **aarch64** architecture.

# Reference
- [Getting started with Docker on ARM (from community.arm.com)](https://community.arm.com/developer/tools-software/tools/b/tools-software-ides-blog/posts/getting-started-with-docker-on-arm)
- [Docker desktop product manuals: Docker Buildx](https://docs.docker.com/buildx/working-with-buildx/)
