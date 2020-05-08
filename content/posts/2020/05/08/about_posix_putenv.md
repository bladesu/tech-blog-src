+++ 
draft = true
date = 2020-05-08T09:34:44+08:00
title = "Do not call putenv() with a pointer to an automatic variable as the argument"
description = "Here is the result: Do not call putenv() with a pointer to an automatic variable as the argument. getenv just collect the pointer to the name=value string rather than coping it. And I found the rules defined by CERT about C programing. That is cool!"
slug = "" 
tags = ["posix", "process", "putenv"]
categories = []
externalLink = ""
series = []
+++
New post here:[https://bladesu.github.io/learning/linux_app/process/auto_vara_n_putenv](https://bladesu.github.io/learning/linux_app/process/auto_vara_n_putenv)

Here is the result of my: __Do not call putenv() with a pointer to an automatic variable as the argument__. 
This quite simple rule take me some time to find out why. And a little surprise here, I find there are the rules defined by CERT about C programing. That is cool! Good job, physicists.