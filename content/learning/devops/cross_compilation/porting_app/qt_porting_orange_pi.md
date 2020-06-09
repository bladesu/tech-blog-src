---
title: "An cross-compiling exercise: porting Qt Application to ARM-base environment with docker environment.
"
date: 2020-06-08T22:01:29+08:00
draft: true
tags: ["arm", "cross_compile", "qt", "docker"]
---


Recently I finish a exercise  that porting Qt-based application from my development environment (Mac OS 10.13.6) to an ARM-based environment(Orange Pi with sunxi H6 SoC). Moreover, I create a docker container as cross-compiling environment with assigned toolchain for ARM.

If we want to run a Qt application on a machine with ARM CPU, we need to prepare built the libraries for Qt runtime. Not only the libraries but the application should be built with the ARM toolchain. Here I leverage docker container as a independent environment to take the role to build the programs, its convenience and isolation with host machine will make the process easier and elegant.

This post would contain following part.


1. Preparation of development platform, Qt, Qt creator, and the application to demonstrate.
2. Preparation for build platform with Docker.
3. Preparation for target environment.



## Preparation on Development platform:

Here I use LTS version 5.9 with it newest patch 5.9.9. Download the source code of qt and "Qt creator" with corresponding version in your development machine. In my case, it is Mac OS. You could find download information in the link: [https://www.qt.io/download](https://www.qt.io/download). It should need registration for new user.

First I choose a calculator program in example of "Qt creator" as our first one to port.
![Example](/learning/devops/cross_compilation/porting_app/qt_creator1.png)

Of course, I have to make sure it process fine in my development environment.
![Example](/learning/devops/cross_compilation/porting_app/qt_creator2.png)


## Preparation on Build platform:

I had written a __Dockerfile__ in my [repo](https://github.com/bladesu/cross_compilation_vscode_dev/). If you follow the steps and start docker container in the workspace of orang_pi. You could get a toolchain provided by sunxi. I would not talk about the detail of how to build this docker container. Because you can use a traditional virtual machine to do this. For orange pi, you can get pre-built toolchain is their official github [repo](https://github.com/orangepi-xunlong/toolchain) which is available on ubuntu 14.04.


### 1. Compiling Qt
There are two important points to remind you:

  1. Change the PATH, make sure you can execute compiler in the executable compiler, assemblers, linker in the toolchain. For example:

```shell
# The toolchain location here: /persistent_data/OrangePiH6_Linux4.9/toolchain/gcc-linaro-4.9-2015.01-x86_64_aarch64-linux-gnu/bin/
export PATH=/persistent_data/OrangePiH6_Linux4.9/toolchain/gcc-linaro-4.9-2015.01-x86_64_aarch64-linux-gnu/bin:$PATH
```

  If the toolchain is not set properly, you may found error about CPU register luckily in the compiling time or found built executable program fails to process in target environment.

  2. For user want to compile Qt in a mounted storage, you probably would encounter a special error, __file not recognized: File truncated__ for some object file. Just try to use naive storage in the build machine.

Now, let’s move on to build Qt, please check every step is processed proper and check every error. The following one is the parameters for this target environment.

```shell
# 1. configure to build makefile
./configure --recheck -qt-gfx-vnc  -prefix /opt/qt-arm-5.9.9 -opensource -confirm-license  -xplatform linux-aarch64-gnu-g++  -nomake tools -nomake examples -no-openssl -no-opengl
# 2.  Compile every component.
make
# 3. Install/link/deploy all component to build machine.
make install
```
Here I install Qt to the machine in the /opt directory. It is the corresponding location on target platform. If no error happens, compress the Qt in /opt and transfer it to the location in target machine.

On build platform:
```shell
# compress qt
tar -czvf qt-arm-5.9.9.tar.gz ./qt-arm-5.9.9/
# send to target machine by rsync (if ssh connection is available)
rsync -avP qt-arm-5.9.9.tar.gz orangepi@192.168.2.4:~/ 
```
And then on target platform:
```shell
# login and extract the tar file to opt.
orangepi@OrangePi:~$ tar -vxf qt-arm-5.9.9.tar.gz /opt/
```

### Compiling application:
With built Qt tool, qmake. we can get proper Makefile with leverage to our built Qt environment and libraries. And there are still some trick for this application porting.

1. set Path to the built qmake.
```shell
export PATH=/opt/qt-arm-5.9.9/bin/:$PATH
```

After some try-and-error, I found the target application needs other code in the examples folder in “qt creator”. So just copy all of them to build platform.
```shell
Qt5.9.9
├── 5.9.9
├── Docs
├── Examples <== all of this!!!!!
├── InstallationLog.txt
├── Licenses
├── MaintenanceTool.app
├── MaintenanceTool.dat
├── MaintenanceTool.ini
├── Qt\ Creator.app
├── components.xml
├── dist
└── network.xml
```
2. Do follwoing steps in directory: __Examples/Qt-5.9.9/quick/demos/calqlatr/__ 
```shell
# make calqlatr.pro
qmake -project
# modify calqlatr.pro, add "QT += qml quick" which is lacked.
echo "QT += qml quick" >> calqlatr.pro
# create Makefile
qmake
# build the executable program.
make
```

### Preparation on target platform: 

To demo the ported application, we need to do some additional works.
1. Install vncserver and run it.
    This program is used to build the GUI interface for remote client. There are many resource about the installation on the internet, please find out the proper way for your target platform. Please run it, and set a password. The default port to connect should be 5900
2. Setup library path and other environment:
    We had deployed Qt and our application onto the target before. However the runtime could not run if not proper setup. In this case, I will make a setup script as follwoing and __source__ it (linux commend).
    ```shell
    # link to libraries
    export LD_LIBRARY_PATH=/opt/qt5.9.9-arm/lib:$LD_LIBRARY_PATH
    # link to plugins
    export QT_QPA_PLATFORM_PLUGIN_PATH=/opt/qt5.9.9-arm/plugins
    # for display fonts
    export QT_QPA_FONTDIR=/usr/share/fonts/truetype/dejavu/
    ```

Finally, I can run the calculator!!!

```shell
orangepi@OrangePi:~$ ./calqlatr -platform vnc:size=400x600
QVncServer created on port 5900
```
A VNC client is needed to see the GUI. I use "VNC Viewer" in MacOS.

![Example](/learning/devops/cross_compilation/porting_app/calqlatr_vnc.png)

