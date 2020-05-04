---
title: "Posix API:mkstemp, why it needs a char array as input."
date: 2020-04-30T16:00:03+08:00
draft: true
tags: ["mkstemp", "posix"]
---

Sometimes we need a temporary file to store data in our implementation. For development on linux platform, a convenient choice is writing a file under the folder __/tmp__. After reboot of OS, those files at least is not persist anymore. However, it needs more consideration to such a “temporary” file. For example, considering about uniqueness. It could be a bad idea that a hardcode file name for a program which could have multiple instances.

Here a useful system call is __mkstemp()__.

```c
#include <stdlib.h>
int mkstemp(char *template);
//Returns file descriptor on success, or –1 on error 
```

You can make a get a open file descriptor by call this function with given a __char array__ (__template__)ended with 6 “X” and ‘\0’. For example:__"/tmp/my_tempXXXXXX"__. Here I must emphasize this pointer again, it should be a __char array__. Or it will cause __segmentation fault__ if it received a __char pointer__ to __string literal__. It could be confused for people. Why? Let us look few lines of  ocde in __posix__ source code as example.

__Code : glibc/sysdeps/posix/tempname.c__
```c
...(skiped)
Int
__gen_tempname (char *tmpl, int suffixlen, int flags, int kind)
  int len;
  char *XXXXXX;
...(skiped)
/* This is where the Xs start.  */
XXXXXX = &tmpl[len - 6 - suffixlen];
/* Get some more or less random data.  */
RANDOM_BITS (value);
value ^= (uint64_t)__getpid () << 32;
for (count = 0; count < attempts; value += 7777, ++count)
  {
    uint64_t v = value;
    /* Fill in the random bits.  */
    XXXXXX[0] = letters[v % 62];
    v /= 62;
    XXXXXX[1] = letters[v % 62];
    v /= 62;
    XXXXXX[2] = letters[v % 62];
    v /= 62;
    XXXXXX[3] = letters[v % 62];
    v /= 62;
    XXXXXX[4] = letters[v % 62];
    v /= 62;
    XXXXXX[5] = letters[v % 62];
...(skiped)

```
Here __*tmpl__ is the argument which is the given __char array__ we talk above. A __char array__ declared in our code should always located in the __stack memory__. And the data will be changed in this code by replacement with rundown bits. __Finally it become the generated unique file name.__ If we call __mkstemp()__ by giving it a pointer to string literal, it will absolutely cause a segmentation fault because the memory is located at __DATA data segment__. It is not changeable in the runtime. 

Finally, it should connect to another system call __unlink()__ which will delete a file with a filename. The common usage with __mkstemp__ is involved about the char array which is changed. This two system calls cooperate together with the __char array__ and control the life-cycle of the temporary file. As the following code block, you can see a example in the code.


 From [https://github.com/bladesu/linux_app_practice/blob/master/file_io/task_check_duplicated_fd.c](https://github.com/bladesu/linux_app_practice/blob/master/file_io/task_check_duplicated_fd.c)
```
...(skiped)
    char template[] = "/tmp/tempXXXXXX";
    fd = mkstemp(template);
...(skiped, do something with mkstemp())
final:
...(skiped)
    if (template != NULL)
        unlink(template);
```


__Complementary material__

Temporary files: RAM or disk? [:link](https://lwn.net/Articles/499410/)

__Reference__

Section 5.12, The Linux Programming Interface.