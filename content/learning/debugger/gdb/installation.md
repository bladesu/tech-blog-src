---
title: "Installation"
date: 2020-03-12T15:30:58+08:00
draft: true
---

# GDB

in Ubuntu:
```
sudo apt-get install gdb
```

# GDB dashborad(Recommended)

A good UI written using Python API that enables a modular interface showing relevant information about the program being debugged. 

```
# Get .gdbinit file to user home.
wget -P ~ https://git.io/.gdbinit
```
Usage: the dashborad will be invoked when running goal process in GDB.
