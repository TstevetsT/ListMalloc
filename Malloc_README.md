BRK(2)                     Linux Programmer's Manual                    BRK(2)

NAME
       l_malloc

SYNOPSIS
       int brk(void *addr);

       void *sbrk(intptr_t increment);
       
DESCRIPTION
        Allocated Block
       ---------------------
       ||  Size + Status  ||
       ---------------------
       ||  User Space     ||
       ---------------------
       
             Free Block
       ----------------------
       ||  Size + Status    ||
       ----------------------
       ||   Forward PTR  ||
       ----------------------
       ||  Back PTR        ||
       ----------------------
       ||  Free Space       ||
       ----------------------
       
 
 RETURN VALUE
       On success, brk() returns zero.  On error, -1 is returned, and errno is
       set to ENOMEM.  (But see Linux Notes below.)

       On  success,  sbrk() returns the previous program break.  (If the break
       was increased, then this value is a pointer to the start of  the  newly
       allocated memory).  On error, (void *) -1 is returned, and errno is set
       
 NOTES
       Avoid using brk() and sbrk(): the malloc(3) memory  allocation  package
       is the portable and comfortable way of allocating memory.

       Various  systems  use various types for the argument of sbrk().  Common
       are int, ssize_t, ptrdiff_t, intptr_t.