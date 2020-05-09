---
title: "Do not call putenv() with a pointer to an automatic variable as the argument"
date: 2020-05-07T18:01:18+08:00
draft: true
tags: ["posix", "process", "putenv"]
---

Recently I study the chapters in the book: __The Linux Programming Interface__, and make exercises in the end of every chapters. Here I get some extra information in a exercise to implement setenv() and unetenv() functionn using getenv() and putenv() in chapter 6. They are used to handling the __environment variable__ within a process including adding or removing one. Here is the complete problem:

>(6.3) Implement __setenv()__ and __unsetenv()__ using __getenv()__, __putenv()__, and, where necessary, code that directly modifies environ. Your version of __unsetenv()__ should check to see whether there are multiple definitions of an environment variable, and remove them all (which is what the glibc version of __unsetenv()__ does).

First, we should see about the spec, to shorten the story, let us see the two main roles in this article:

```c
int setenv(const char *name, const char *value, int overwrite);
```

```c
int putenv(char *string);
```
These two functions could be included in <stdlib.h>, both can modify the environment list.  It seems to make a simple version of setenv() by wrapping putenv() and getenv(). I write a first version of setenv(), it contains some flow control with parsed input string.

code: __setenv1__() link:[https://github.com/bladesu/linux_app_practice/blob/master/process/impl_setenv_unsetenv.c](https://github.com/bladesu/linux_app_practice/blob/master/process/impl_setenv_unsetenv.c)
```c
int setenv1(const char *name, const char *value, int overwrite)
{
    // check should the value be overwrite.
    char *value_ori = getenv(name);
    if (value_ori != NULL && strcmp(value_ori, value) == 0)
        return 0;

    char str[strlen(name) + strlen(value) + 2];

    if (sprintf(str, "%s=%s", name, value) < 0)
        printf("Fail to create string\n");

    if (value_ori)
    {
        if (overwrite == 0 || putenv(str) != 0)
            return -1;
        return 0;
    }
    else
    {
        if (putenv(str) != 0)
            return -1;
        return 0;
    }
}
```
However, it could be wrong. You may find the environment would disappear after insertion (not absolutely). After some try and error. I found it will disappear after the inserted name and value string (which is located in __statck memory__ in version 1) was overwritten in __stack__. Here I examine it by write a recursive loop aimed to overwrite certain address. I use it to overwrite the target of address I get from __getenv()__. And the problem is reproducible now.

code: __stry_overwrite()__ link:[https://github.com/bladesu/linux_app_practice/blob/master/process/impl_setenv_unsetenv.c](https://github.com/bladesu/linux_app_practice/blob/master/process/impl_setenv_unsetenv.c)
```c
static int lc = 0;
static int loop_max = 1024; // prevent endless loop.
void try_overwrite(void *p)
{
    int temp = 0;
    // check this stack address is smaller than p.
    if ((&temp) < (int *)p)
        return;

    if (lc < loop_max)
    {
        lc++;
        try_overwrite(p);
    }
}
``` 

And then I make other version to fix the problem by assign a __heap memory__ to put the name=value string. However, it probably induce __memory leak__.

ode: __try_overwrite()__ link:[https://github.com/bladesu/linux_app_practice/blob/master/process/impl_setenv_unsetenv.c](https://github.com/bladesu/linux_app_practice/blob/master/process/impl_setenv_unsetenv.c)
```c
int setenv2(const char *name, const char *value, int overwrite)
{
    // check should the value be overwrite.
    char *value_ori = getenv(name);
    if (value_ori != NULL && strcmp(value_ori, value) == 0)
        return 0;

    char *str = malloc(strlen(name) + strlen(value) + 2);
    if (str == NULL || sprintf(str, "%s=%s", name, value) < 0)
    {
        errno = ENOMEM;
        return -1;
    }

    if (value_ori)
    {
        if (overwrite == 0 || putenv(str) != 0)
            return -1;
        return 0;
    }
    else
    {
        if (putenv(str) != 0)
            return -1;
        return 0;
    }
}
```

Finally, I found it is not a new problem. I found it is noted in __SEI CERT C Coding Standard__ about POSIX part. It clearly indicated that getenv just collect the pointer to the name=value string rather than coping it. That is cool, I should learn it early to save my time, but I gain something in this try and error process.

Reference:

- man page for setenv: [http://man7.org/linux/man-pages/man3/setenv.3.html](http://man7.org/linux/man-pages/man3/setenv.3.html)
- man page for putenv: [http://man7.org/linux/man-pages/man3/putenv.3.html](http://man7.org/linux/man-pages/man3/putenv.3.html)
- man page for getenv: [http://man7.org/linux/man-pages/man3/getenv.3.html](http://man7.org/linux/man-pages/man3/getenv.3.html)
- man page for unsetenv: [http://man7.org/linux/man-pages/man3/unsetenv.3.html](http://man7.org/linux/man-pages/man3/unsetenv.3.html)
- SEI CERT C Coding Standard: [https://wiki.sei.cmu.edu/confluence/display/c/SEI+CERT+C+Coding+Standard](https://wiki.sei.cmu.edu/confluence/display/c/SEI+CERT+C+Coding+Standard)