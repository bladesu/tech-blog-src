+++ 
draft = false
date = 2020-03-03T22:22:27+08:00
title = "Coding in C, C standard should be most reliable reference material than everything."
description = "A story about answer finding in c coding. Finally, you will find definition and description in C standard should be most valuable than other extended ones or personal guessing."
slug = "" 
tags = []
categories = ["c language"]
externalLink = ""
series = []
+++

Recently, I start to code a lot in c language. One of my studying 
material is "Head First C" written by David Griffith. And I am so confused about an example it talking about XOR encrption.

```c
void encrpt(char *mes)
{
    while (*mes) {
        *mes = *mes ^ 31;
        mes++; }
    }
}
```

This code could be compiled without any error or warning (Apple LLVM version 9.1.0 (clang-902.0.39.1)). But I am really curious about how XOR operator worker on the two operand __*mes__ and the integer literal __31__. So I write a test code to show the binary format of two operands to understand the behavior. (https://github.com/bladesu/c_practices/blob/master/src/basic/bitwise_op.c)


```c
void print_bit(void *const obj, unsigned long const bit_size)
{
    // For bitwise AND operator,
    // the each of operands shall have integer type according to C99 standard (6.5.10) 
    unsigned int *x = obj;
    unsigned long leftest = 8 * bit_size;
    while (leftest > 0)
    {
        leftest--;
        (*x & (1 << leftest)) ? putchar('1') : putchar('0');
        if (!(leftest % 8))
            putchar(' ');
    }
    putchar('\n');
}
```

In this function, a pointer was introduced by argument __void *obj__. And it was taken as pointer to unsigned integer. Then the second argument __bit_size__ is given as bit size which is also the location of leftest digital of the type. It should be noted that the iteraly-print part.
```
(*x & (1 << leftest)) ? putchar('1') : putchar('0');
```
It applies __bit-wise AND operator(&)__ onto operands __*x__ and __(1 << leftest)__, and print __1__ or __0__ char by char. In my older version, __*x__ is defined by __unsigned long long__, becase I thought it should take a longest data type to accept the __*obj__, and __bit_size__ as the role to shrink the requested range. However the result is wrong, I do not want to talk about how it be wrong now. Here I want to talk about the referenced material. I had read a lot of example code from the some googled article and forum. None of them use __unsigned long long *__, alternatively they use __unsigned char__, __unsigned int__ or __int__. It confused me more, how could they be right in the same time. They even do not have same bit size! Finally I go to read the holy C99 standard(I refer to this one: Committee Draft — Septermber 7, 2007 ISO/IEC 9899:TC3).

In sections ___6.5.10___ and ___6.5.11___, each of the operands shall have integer type for __bitwise AND operator__ and __bitwise exclusive OR operator__ and . We should know all C compiler should follow the C standard. In most case, we should avoid invalid syntax usage to result in unexpected behavior. In other words, we should not consider the codes with non-integer type operand bitwise operation. Finally, we should always take definition and description in C standard as most valuable material than other extended ones or personal guessing.
