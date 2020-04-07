---
title: "Basic_usage"
date: 2020-03-12T16:30:55+08:00
draft: true
---

# First: Add debug option when compiling.

------

GDB needs the debugging information provided by compiler. The debugger option should be on when generating object file for code line number or others.

### For C language compiled by GCC:
In general, use -g option, according to GCC documentation:

> **-g** Produce debugging information in the operating system's native format (stabs, COFF, XCOFF, or DWARF 2). **GDB** can work with this debugging information.

```bash
# To build a object file: obj.o from src.c
gcc -g -c -o obj.o src.c
# To build executable file: program.exe from src.c
gcc -g -o program.exe src.c

```
------
# Run GDB with executable program.

For a compiled program: progrom.exe. We can run GDB onto it, then set a break point and run.
```bash
# For a executable program: program.exe
gdb program.exe
```
Above operation will start GDB, and you will see a cursor waiting for typing behind following info:
```bash
Copyright (C) 2014 Free Software Foundation, Inc.
License GPLv3+: GNU GPL version 3 or later <http://gnu.org/licenses/gpl.html>
This is free software: you are free to change and redistribute it.
There is NO WARRANTY, to the extent permitted by law.  Type "show copying"
and "show warranty" for details.
This GDB was configured as "x86_64-linux-gnu".
Type "show configuration" for configuration details.
For bug reporting instructions, please see:
<http://www.gnu.org/software/gdb/bugs/>.
Find the GDB manual and other documentation resources online at:
<http://www.gnu.org/software/gdb/documentation/>.
For help, type "help".
Type "apropos word" to search for commands related to "word"...
Reading symbols from bin/example_1...done.
>>>   
```

Currently the process of the program is not executed yet until type "run" and execute in the GDB console. However, a break pointer should be set before "run" the process. Here I set break point on the main entry in a C code.

```c
/* Content of example_1.c */
int main(int argc, char *argv[])
{
    unsigned int i = 0;
    return 0;
}
```

```bash
# Set break point and run in GDB console.
>>> break main
Breakpoint 1 at 0x4004f8: file example_1.c, line 3.
>>> run
```

```bash
# Running GDB with GDB dashboard.
─── Output/messages ──────────────────────────────────────────────────────────────────────────────────────────────────────────────

Breakpoint 1, main (argc=1, argv=0x7ffe4bd325c8) at example_1.c:3
3           unsigned int i = 0;
─── Assembly ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
~
 0x00000000004004ed  main+0  push   %rbp
 0x00000000004004ee  main+1  mov    %rsp,%rbp
 0x00000000004004f1  main+4  mov    %edi,-0x14(%rbp)
 0x00000000004004f4  main+7  mov    %rsi,-0x20(%rbp)
!0x00000000004004f8  main+11 movl   $0x0,-0x4(%rbp)
 0x00000000004004ff  main+18 mov    $0x0,%eax
 0x0000000000400504  main+23 pop    %rbp
 0x0000000000400505  main+24 retq   
~
─── Breakpoints ──────────────────────────────────────────────────────────────────────────────────────────────────────────────────
[1] break at 0x00000000004004f8 in example_1.c:3 for main hit 1 time
─── Expressions ──────────────────────────────────────────────────────────────────────────────────────────────────────────────────
─── History ──────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
─── Memory ───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
─── Registers ────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
        rax 0x00000000004004ed           rbx 0x0000000000000000        rcx 0x0000000000000000        rdx 0x00007ffe4bd325d8
        rsi 0x00007ffe4bd325c8           rdi 0x0000000000000001        rbp 0x00007ffe4bd324e0        rsp 0x00007ffe4bd324e0
         r8 0x00007f4e7949ee80            r9 0x00007f4e794b4600        r10 0x00007ffe4bd32370        r11 0x00007f4e790fce50
        r12 0x0000000000400400           r13 0x00007ffe4bd325c0        r14 0x0000000000000000        r15 0x0000000000000000
        rip 0x00000000004004f8        eflags [ PF ZF IF ]               cs 0x00000033                 ss 0x0000002b        
         ds 0x00000000                    es 0x00000000                 fs 0x00000000                 gs 0x00000000        
─── Source ───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
~
~
~
 1  int main(int argc, char *argv[])
 2  {
!3      unsigned int i = 0;
 4      return 0;
 5  }
~
~
─── Stack ────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
[0] from 0x00000000004004f8 in main+11 at example_1.c:3
─── Threads ──────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
[1] id 781 name example_1 from 0x00000000004004f8 in main+11 at example_1.c:3
─── Variables ────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
arg argc = 1, argv = 0x7ffe4bd325c8: 47 '/'
loc i = 0
──────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
>>> 
```

Run next instruction, type **"next"** and execute:
```bash
# Go to next line
>>> next
```

Jump to assigned line in source code, type **"jump #line"** and execute:
```bash
# Jump to line 1:
>>> jump 1
```

After all line executed, you will see information like following ones:
```
─── Variables ────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
arg main = 0x4004ed <main>: {int (int, char **, char **)} 0x4004ed <main>, argc = 1, argv = 0x7ffe4bd325c8: 47 '/', init = <optimized out>, fini = <optimized out>, rtld_fini = <optimized out>, stack_end = 0x7ffe4bd325b8
loc result = 0, unwind_buf = {cancel_jmp_buf = {[0] = {jmp_buf = {[0] = 0, [1] = 7105966841129512735, [2] = 4195328, [3] = 140730…, not_first_call = <optimized out>
─
```
Give any key, it will show information that the process is done:
```bash
─── Output/messages ──────────────────────────────────────────────────────────────────────────────────────────────────────────────
[Inferior 1 (process 794) exited normally]
>>> 
The program is not being run.
```
To exit **GDB**, type **"q"**:
```bash
>>> q
```
