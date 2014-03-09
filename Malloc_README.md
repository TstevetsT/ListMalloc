BRK(2)                     Linux Programmer's Manual                    BRK(2)

NAME
       l_malloc

SYNOPSIS
       int brk(void *addr);

       void *sbrk(intptr_t increment);
       
DESCRIPTION

        Allocated Blocks
       ---------------------
       ||  Size + Status  ||	4 Bytes Lowest Byte is used for Flags
       ---------------------
       ||  User Space     ||  Space available to the calling process
       ---------------------
       
            Free Blocks
       ----------------------
       ||  Size + Status    ||  4 Bytes Lowest Byte is used for Flags
       ----------------------
       ||  Forward PTR      ||  4 Byte Pointer to the block prior
       ----------------------
       ||  Back PTR         ||  4 Byte Pointer to the next block
       ----------------------
       ||  Free Space       ||  Available Space for allocation
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