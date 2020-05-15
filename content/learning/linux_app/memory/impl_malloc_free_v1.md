---
title: "Simple implementation of malloc and free with sbrk system call."
date: 2020-05-15T14:28:30+08:00
draft: true
tags: ["glic", "posix", "memory", "malloc", "free"]
---


To get familiar with heap memory operation in linux, I try to implement a easy one of __malloc__ and __free__ with leverage of system call __sbrk()__.
```c
void *malloc(size_t size);
// return pointer to allocted heap memory with assigned size.
```
```c
void free(void *ptr);
// release the allocated heap memory with *ptr.
```
```c
void * sbrk(intptr_t incr);
// return prior program break.
```
First, we start the topic with some notes about __sbrk__:
- The current value of the __program break__ may be determined by calling sbrk(0).
- The __sbrk()__ function raises the __program break__ by incr bytes, thus allocating at least incr	bytes of new memory in the data	segment.
- The __sbrk()__ function returns the __prior program break__ value if successful; otherwise the value __(void *)-1__ is returned and the global variable errno is set to indicate the error.

__malloc()__ and __free()__ are wrapper functions of __brk()__ and __sbrk()__ to manipulate __program break__ and maintain a __free list__ holding current unused segment in heap memory. It could decrease the frequency of using system call for moving __program break__ by dispatching and recycling memory within this __free list__. 

Then we talk about my implementation, here is the link: [https://github.com/bladesu/linux_app_practice/blob/master/memory_allocate/impl_malloc_free.c](https://github.com/bladesu/linux_app_practice/blob/master/memory_allocate/impl_malloc_free.c)


The definition of struct for memory block in free list call __MBLOCK__ in my implementation. Here I define last = __NULL__ for the first one in free list and next = __NULL__ for tail one. In my implementation, a little track here is that the tail block can not be returned or merged into larger block for shorten the flow control and reducing the number of code.
```c
typedef struct __MBL
{
    size_t length;
    struct __MBL *last;
    struct __MBL *next;
} MBLOCK;
```
In heap memory, a __MBLCOK__ should look like following adjacent pattern:
```c
Low memory address  --> high memory address

MBLOCK *block= 0x50000000                      MBLOCK *next_block= 0x50000100
↓        |<----------length=0xff------------->|↓
[lengthL][addressL][addressL]     ...          [lengthL][addressL][addressL]]
↥        ↥         ↥                           
↥        ↥         content=(address to next free block)=0x500000ff
↥        content=(address to last free block)=...
content=0xff
```
For a dispatched heap memory segment with required length = length1, it would look like following pattern:
```c
Low memory address  --> high memory address

         ↓head of dispatched block 0x50000008     ↓head of other free block  
[lengthL][  some data   ]        ...              [lengthL][addressL][addressL] ...
↥        |<-- length1-->|         
↥
content=length1
```

Next, we are going to talk about some complicated part in the impl. I think most difficult part is considering the boundary of data. Let us look some implemented function.

About the idea of split() function, which to split free block with __assiged length__ into allocated one (left) and smaller free block(right).
```c
/* Original block on free list*/
↓head of free block (MBLOCK)
[lengthL][addressL][addressL][<-               __free_space1                   ->]
         |<------------------------ "block->length" ---------------------------->|
/* Split one free block into two */                                             
         ↓head allocated block       ↓remained free block                         
[lengthL][<-   allocated space    ->][lengthL][addressL][addressL][ __free_space2]
         |<-   assigned length    ->|                                             
```
- code of split():
```c
void split(MBLOCK *_block, const size_t _length)
{
    MBLOCK *right = (MBLOCK *)(((void *)_block) + _length + sizeof(size_t));
    right->next = _block->next;
    right->last = _block->last;
    right->length = _block->length - _length - sizeof(size_t);

    MBLOCK *left = _block;
    left->length = _length;
    // It is __HEAD
    if (_block->last == NULL)
    {
        // move __HEAD to right
        __HEAD = right;
    }
}
```
A critical part I think that is the heap memory expansion when no more available heap space to provide. Here the function __expand_newblock(MBLOCK *last_block, intptr_t _length) attach a space to current __program break__ and make a new block to free list.

- idea of __expand_newblock()
```c
1. Current end of memory around program break.
     (current program break)↓
[lengthL][addressL][addressL]

2. Expansion for requested _length byte.
                                                             
[lengthL][addressL][addressL][   "_length" - 2 * addressL    ]
Asked    |<----------------- "_length" --------------------->|                           
Expanded mem_size            |<----------------------------->|[lengthL][addressL][addressL]
                                                                       (new program break)↥
// Therefore, 
// Expanded = _length + (- 2 * addressL + 2 * addressL)  + lengthL. = _length + lengthL
```

- code: __expand_newblock()

```c
/*
    append new allocated heap space to last_block.
*/
void *__expand_newblock(MBLOCK *last_block, intptr_t _length)
{
    intptr_t mem_size = (_length > _ALLOCK_INTERVAL) ? _length + sizeof(size_t) : _ALLOCK_INTERVAL;
    void *ptr;
    // EXPAND __CURRENT_HEAP_PTR
    if ((ptr = __get_expanded_heap(mem_size)) != NULL)
        __CURRENT_HEAP_PTR = ptr;
    else
        return NULL;
    // attach new block
    last_block->length = _length;
    last_block->next = __CURRENT_HEAP_PTR - sizeof(MBLOCK) + sizeof(size_t);
    // fill data of the new block.
    last_block->next->last = last_block;
    last_block = last_block->next;
    last_block->length = sizeof(MBLOCK) - sizeof(size_t);
    last_block->next = NULL;
    return ptr;
}
```
About __free()__, there are 3 induced cases in this implementation. It should be noted the block to join back to free list would not located after the least one of free block.

- case 1: The block to join is located in front of first free block.
```c
[ block to join ]       [ first free block ]
```
- case 2: The block to join is located in front of first free block with no additional space.
```c
[ block to join ][ first free block ]
```
- case 3: The block to join is located between two free block.
[ free block i ]  [ block to join ] [ free block i+1 ]

More detail in my github: [https://github.com/bladesu/linux_app_practice/blob/master/memory_allocate/impl_malloc_free.c](https://github.com/bladesu/linux_app_practice/blob/master/memory_allocate/impl_malloc_free.c)




References:
- Document about sbrk(): [https://www.freebsd.org/cgi/man.cgi?query=sbrk&sektion=2](https://www.freebsd.org/cgi/man.cgi?query=sbrk&sektion=2)
- Document about malloc(): [http://man7.org/linux/man-pages/man3/malloc.3.html](http://man7.org/linux/man-pages/man3/malloc.3.html)
- Document about free(): [https://linux.die.net/man/3/free](https://linux.die.net/man/3/free)
