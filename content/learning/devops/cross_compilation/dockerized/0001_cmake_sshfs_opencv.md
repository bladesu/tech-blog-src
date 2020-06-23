---
title: "Apply cmake and pkg-config with mounted target root file system"
date: 2020-06-23T16:19:22+08:00
draft: true
tags: ["pynq", "docker", "cross_compile", "arm", "linaro"]
---

git repository: [link](https://github.com/bladesu/demo-cross-compile-opencv-with-docker-for-pynq-z2)

This is a project that I try to make a cross-compile environment which link to libraries of target’s platform with sshfs in a light-weight docker container. I try to compile OpenCV 3.4.10 for the the target board PYNQ-Z2 with Xilinx XC7Z020-1CLG400C SOC.

First, I try to dig the toolchain applied in the board by __gcc -v__

```shell
xilinx@pynq:/usr/local/bin$ gcc -v
Using built-in specs.
COLLECT_GCC=gcc
COLLECT_LTO_WRAPPER=/usr/lib/gcc/arm-linux-gnueabihf/7/lto-wrapper
Target: arm-linux-gnueabihf
Configured with: ../src/configure -v --with-pkgversion='Ubuntu/Linaro 7.3.0-16ubuntu3' --with-bugurl=file:///usr/share/doc/gcc-7/README.Bugs --enable-languages=c,ada,c++,go,d,fortran,objc,obj-c++ --prefix=/usr --with-gcc-major-version-only --with-as=/usr/bin/arm-linux-gnueabihf-as --with-ld=/usr/bin/arm-linux-gnueabihf-ld --program-suffix=-7 --program-prefix=arm-linux-gnueabihf- --enable-shared --enable-linker-build-id --libexecdir=/usr/lib --without-included-gettext --enable-threads=posix --libdir=/usr/lib --enable-nls --with-sysroot=/ --enable-clocale=gnu --enable-libstdcxx-debug --enable-libstdcxx-time=yes --with-default-libstdcxx-abi=new --enable-gnu-unique-object --disable-libitm --disable-libquadmath --disable-libquadmath-support --enable-plugin --enable-default-pie --with-system-zlib --with-target-system-zlib --enable-objc-gc=auto --enable-multiarch --enable-multilib --disable-sjlj-exceptions --with-arch=armv7-a --with-fpu=vfpv3-d16 --with-float=hard --with-mode=thumb --disable-werror --enable-multilib --enable-checking=release --build=arm-linux-gnueabihf --host=arm-linux-gnueabihf --target=arm-linux-gnueabihf
Thread model: posix
gcc version 7.3.0 (Ubuntu/Linaro 7.3.0-16ubuntu3)
```
Apparently it is arm-linux-gnueabihf provided Linaro. That is for 32-bit Armv7 Cortex-A, hard-float, little-endian. Linaro provides previous version built binary gcc tool in their website: [http://releases.linaro.org/components/toolchain/binaries/](http://releases.linaro.org/components/toolchain/binaries/).


In this process, it needs the dependency of library installed on the board root file system. The package management is __pkg-config__. So I link the folder of the target platform containing the .pc files, which provides information for __pkg-config__, and then run cmake to build Makefile and dependency. However, I found it has some package on the board can not be recognized for example GTK, but this approach still can provide a easier and simpler environment to build application for cross compilation with a existed target root file system. Of course, there is more general way to build that. For example, Yocto project for general target or PetaLinux for Xilinx SOC.  You can read more detail in the attached GitHub repo.