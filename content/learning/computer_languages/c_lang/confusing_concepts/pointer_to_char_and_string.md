---
title: "Some confusing issue for processing string in C language."
date: 2020-03-23T23:09:24+08:00
draft: true
tags: ["c_language"]
---

### Introduction

There is no real primitive **"string"** object in **C language**. From a perspective of data processing, a **string** is a contiguous sequence of characters ended with **'\0'** or so-called **NUL terminator**. The serious properties about **string** had beed defined in **C standard**. For example, session **7.1** in **C99** standard, it would be really gainful to read __C standard__ carefully. Here I introduce some properties we needed to know for writing __C code__. First, two objects could be used when processing **string**, (1) __char array__ and (2) __char *__(pointer to char). Here I will dig out more details in following part. All code demonstrated here can be read in following git repository: [https://github.com/bladesu/c_practices/blob/master/src/basic/string_practice.c](https://github.com/bladesu/c_practices/blob/master/src/basic/string_practice.c)

### Something should be known about __char array__ and __pointer to char__.

- #### Understand char array:

    In __C language__, declaration to a **char array** must have an immediate initialization of **fixed size** memory. Here we talk about some properties in following sections.

    - #### Value of a char array object is just its address.
        __c_code1__: show address with operator act upon char array.
        ```c
        char c_arr[] = "abc";
        printf("(value vs address) = (%p vs %p)\n", c_arr, &c_arr);
        printf("Is they identical?:%s\n", (void *)c_arr == (void *)&c_arr? "Yes":"No");
        ```
        **result**:
        ```console
        (value vs address) = (0x7ffcc4ce8f90 vs 0x7ffcc4ce8f90)
        Is they identical?:Yes
        ```
        In this case, we know there is no other __pointer__, which has independent address, to store address of the char array. The value of the __char array__ object is just the same as its address. There is other special properties that __sizeof__ operator can get the size of contained data in bytes. But this property is not for function argument, we will talk it later.

    - #### Char array initialized with a stirng literal.

        A common way to assign the inital char values is use {} pair to contain the char values. Here a __NUL__ end is declared as __'\0'__ to act like a common string we use.
        
        ```c
        char foo[] = {'a', 'b', 'c', '\0'};
        ```
        
        Other similar way to assign the inital char values to a char array is giving it a __string literal__ (embraced by dobule quotes)to copy values just like assigning value when it is declared (see following code block). However these two approaches are different in many perspective, we will talk about latter.

        ```c
        char foo[] = "abc";
        ```
        
        Some thing should be noted that it is actually no need to assign inital values for each elements in initialization of char array, __only__ size of the array must exist in declaration. In above case, no size was declared becase of a __syntatic sugar__. The size is just the same of the assigned __string literal__.

    - #### More properties about initialization of a char array.

        Next, in following demo code, a char array named __no_init__ with length with two characters long whose value is not pre-assigned, you can see NUL terminator __'\0'__ as default value to such a char array.
        
        __c_code2__: show size and contents in declared char array without assigning values.
        ```c
        char no_init[2];
        printf("sizeof(\"%s\")=%lu\n", "no_init", sizeof(no_init));
        printf("First char in \"%s\":'%c'\n", "no_init", *no_init);
        printf("Is first char equal to NUL terminator(\'\\0\')?:%s\n", *no_init == '\0'? "Yes": "No");
        printf("Is second char equal to NUL terminator(\'\\0\')?:%s\n", *(no_init+1) == '\0'? "Yes": "No");
        ```
        **result**:
        ```console
        sizeof("no_init")=2
        First char in "no_init":''
        Is first char equal to NUL terminator('\0')?:Yes
        Is second char equal to NUL terminator('\0')?:Yes
        ```

        Let's go back to __string literal__, such object has memory address which is not located at __stack__ region. It could be in __code segment__ or somewhere else, it is actually implementation-specific stuff. And this kind of object is reuseful in the runtime, and in most time you can treat it as a char array object in the scenario including __retrival of memory address__(with __&__), __ocuppied memory size__(with __sizeof__), or an argument to function(however char array as argument is usually not a good design of a function).

        __c_code3__: Retrive memory address to the objects point to reusable __string literal__:
        ```c
        char c_arr_op[] = "abc";
        printf("Address Representation1: with address operator\n");
        printf("    Address of string literal \"abc\":%p\n", &"abc");
        printf("    Address of c_arr_op:%p\n", &c_arr_op);

        printf("Address Representation2: without address operator\n");
        printf("    Address of string literal \"abc\":%p\n", "abc");
        printf("    Address of c_arr_op:%p\n", c_arr_op);
        ```
        **result**:
        ```console
        Address Representation1: with address operator
        Address of string literal "abc":0x400f57
        Address of c_arr1:0x7ffec7232ed0
        Address Representation2: without address operator
        Address of string literal "abc":0x400f57
        Address of c_arr1:0x7ffec7232ed0
        ```
        __c_code4__: show the reusable properties of __string literal__ by assigning same __string literal__ to different char pointer.
        ```c
        char * c_arr_op1 = "abc";
        char * c_arr_op2 = "abc";
        printf("%s points to address=%p\n", "c_arr_op1", c_arr_op1 );
        printf("%s points to address=%p\n", "c_arr_op2", c_arr_op2 );
        printf("String literal \"%s\" has address=%p\n", "abc", &"abc");
        ```
        __result__:
        ```console
        c_arr_op1 points to address=0x400fca
        c_arr_op2 points to address=0x400fca
        String literal "abc" has address=0x400fca
        ```
        __c_code5__: show address and values of each elements in a char array initialized with __string literal__. Watch carefully please, they are not located at same memory address. 
        ```c
        char c_arr1[] = "abc";
        printf("Find value and memory address in char array and string literal as target to copied.\n");
        for (int i = 0; i < sizeof(c_arr1); i++)
        {
            printf("Serial order:%d\n", i);
            printf("    In \"%s\": value=%c, address=%p\n", "abc", (char) *( (char*)&"abc" + i), &"abc" + i);
            printf("    In \"%s\": value=%c, address=%p\n", "c_arr1", (char) *((char*)c_arr1 + i), c_arr1 + i);
        }
        ```

        **result**:
        ```console

        Find value and memory address in this two objects:
        Serial order:0
            In "abc": value=a, address=0x400f57
            In "c_arr1": value=a, address=0x7ffec7232ed0
        Serial order:1
            In "abc": value=b, address=0x400f5b
            In "c_arr1": value=b, address=0x7ffec7232ed1
        Serial order:2
            In "abc": value=c, address=0x400f5f
            In "c_arr1": value=c, address=0x7ffec7232ed2
        Serial order:3
            In "abc": value=, address=0x400f63
            In "c_arr1": value=, address=0x7ffec7232ed3
        ``` 


- ### Understand pointer to char:

    To declare a __pointer to char__ object, we can apply __char *__ type and assign value of the head of contigous memory to this point object (usually __pointer to char__ for processing __string__). Compare to __char array__, there is no declaration of actual memory size which will attached to this pointer.
    
    - #### Declarations and initialization:

        - Declarations of a pointer to char without assigning value.
            ```c
            char * c_ptr;
            ```
        - Declarations of a pointer to char with assigning memory address allocated by malloc.
            ```c
            char * c_ptr = malloc(sizeof(char) * 10);
            ```
        - Declarations of a pointer to char with address of a __string literal__ we just talked about.
            ```c
            char * c_ptr = "abc";
            ```
        - Declarations of a __pointer to char__ with address of char array we just talking about in above section. Two assignment way is available we had talked in above section.
            ```c
            char c_arr = "abc";
            char * c_ptr1 = c_arr;
            // or
            char * c_ptr2 = &c_arr;
            ```
    - #### Pointer and address:

        - Address of pointer object and the address it assigned to.

            A pointer in __c language__ has its own memeory address which is allocated to save its value, but this value is a memory address which another data located at. Here we are talking about __pointer to char__, that is, a pointer which is assigned to a address containing data with __char type__.
        
            __c_code6__: show address of a __pointer to char__ and its value:

            ```c
            // define two object:
            char foo = 'a';
            char *char_ptr;
            // assign address of foo to char_ptr
            char_ptr = &foo;
            // display current data details
            printf("|%10s|%18s|%15s|\n", "object", "address", "value(hex|char)");
            printf("|%10s|%18p|%15c|\n", "foo",&foo, foo);
            printf("|%10s|%18p|%15p|\n", "char_ptr",&char_ptr, char_ptr);
            ```

            The complied program shows:

            |object|address|value(hex or char)|
            | --- | --- | --- |
            | foo | **0x7ffc70ae0977** | a |
            | char_ptr | 0x7ffc70ae0978 | **0x7ffc70ae0977** |
            
            It indicated that an object named as **char_ptr** with a type of **pointer to char**, which is assigned to store the address of **foo**. __It should be noted that **char_ptr** own its address which is different from **foo**.
            
### More detail about  __char array__ and __pointer to char__

- #### Understand what is initailized:
        
    - What do you think the size of following __object__.

        __c_code7__: show sizes of __string literal__ and __pointer to char__.
        ```c
        char foo1[] = "abc";
        char foo2[] = {'a','b','c'};
        char *foo3 = "abc";

        printf("sizeof \"%s\" = %lu\n", "abc", sizeof("abc"));
        printf("sizeof %s = %lu\n", "foo1", sizeof(foo1));
        printf("sizeof %s = %lu\n\n", "foo2", sizeof(foo2));

        printf("sizeof %s = %lu\n", "（void*)", sizeof(void *));
        printf("sizeof %s = %lu\n", "foo3", sizeof(foo3));
        ```

        **result**:
        ```
        sizeof "abc" = 4
        sizeof foo1 = 4
        sizeof foo2 = 3

        sizeof（void*) = 8
        sizeof foo3 = 8
        ```

        Here I apply a __sizeof__ operator, it will give the size it opreands during compiling time. However it works in different way according to __operand type__.

        - Array object.

            Apply __sizeof__ operator to array object, it will show the size of the array. I had metioned that the size of a array must be defined in declaration in above section. Therefore it is reasonable that the __sizeof__ operator could give the array size in compile time. In this case, __foo1__ is given a __string literal__ to copied and __foo2__ is given a "{}" enclosed data with char type. The foo has one more hiden data with one byte length. That is a __NUL terminator__('\0') in the end of sequence. Ihis character is usually a normal string ended with
        - Primitive data type and pointer type
            When __sizeof__ is applied to primitive data type(__int__, __double__,...) or pointer type(__char *__, __void *__, self-defined-struct *), it give the amount of memeory is allocated to that type. In above case, sizeof(__void *__) and sizeof(__foo3__) which is a __pointer to char__ have the same memory size "8" in my compiling machine, and the **result** is not related to the size of the assigned value of these object
- ##### Some mistakes probably we make.

    - ##### Some case with application of standard library.

        - ###### For function in __C language__, __string literal__, __char array__ are regarded as the argument equaled to __poiter to char__.

            In **string** processing, there is a fact that function in **C languag** have only single arguement type __pointer to char__ as argument rather than __string literal__ and __char array__. Here I put a little demo that a function implemented with a __char array__ arguemnt. In the end you will see the argument in the function still a __pointer to char__. There is no real __char array__ argument but a  **syntactic sugar** in __C language__. Functions to handle __string__ need to apply the feature of __NUL__ end.

            __c_code8__: try char array as argument to a function.
            ```c
            #include <stdio.h>
            void show_size(char test[])
            {
                printf("%lu\n", sizeof(test));
            }
            void main(void)
            {
                char test[] = "123";
                printf("sizeof a string literal:%lu\n", sizeof("123"));
                printf("sizeof a char array:%lu\n", sizeof(test));
                printf("sizeof a (char *):%lu\n", sizeof(char *));
                show_size("123"); 
                show_size(test);
            }
            ```
            __result__:
            ```console
            sizeof a string literal:4
            sizeof a char array:4
            sizeof a (char *):8
            8
            8
            ```
            In above case, __string literal__ "abc", has four characters 'a', 'b', 'c', '\0'. It counts 4 bytes in main code in the case of __char array__ and __string literal__. When it comes to function arguments, all of the case have the same __sizeof__ result as __char to pointer__. Here is 8 bytes. 



        - ###### printf function in stdio.h

            A easy usage of __printf__ function to print a __string__ like following block:

            ```c
            printf("%s", "abc");
            ```
            And you will see the printed character in console during runtime:
            ```console
            abc
            ```
            We mention that a string is a contiguous sequence of characters terminated with __NUL__. If we apply some strange case like __"abc\0def"__. It will show only the characters before __NUL__ because the library is implemented based on the standard.

            __c_code9__: try printf in stdio.h
            ```c
            char abc1[] = {'a', 'b', 'c','\0'};
            char abc2[] = {'a', 'b', 'c','\0','d', 'e', 'f'};
            printf("%s\n", abc1);
            printf("%s\n", abc2);
            printf("%s\n", "abc\0efg");
            ```
            __result__:
            ```console
            abc
            abc
            abc
            ```

        - ###### strcpy function in string.h

            Similarly, the strcpy function to copy string is based on the definition of __string__. It will copy the data from a __char pointer__.

            
            __c_code10__: try strcpy in string.h
            ```c
            char *char_p1;
            strcpy(char_p1, "abc\0def");
            printf("%s\n", char_p1);
            ```
            __result__:
            ```
            abc
            ```

            In above function, I use a __string literal__ as argument to __strcpy__ function. It is available for __string__ processing. However, __string literal__ and __char array__ in __C language__ will finally be treated as __pointer to char__ in compiling.

            Here is a wrong usage of __strcpy__, when you try to apply a __strcpy__ to copy data from a address stored in a __char **__ point to storage which located at address of __string literal__, in other word, a read-only region. It will cause a __segmentation fault__ in the runtime.

            __c_code11__: wrong use case in strcpy in string.h
            ```c
            char * str_literal_1 = "abc";
            char * char_arr_test = "def";
            //Segmentation fault
            strcpy(str_literal_1, char_arr_test);
            ```
            __result__
            ```console
            Segmentation fault
            ```

            
