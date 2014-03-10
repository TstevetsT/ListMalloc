BRK(2)                     Linux Programmer's Manual                    BRK(2)

NAME

       l_malloc

SYNOPSIS

       void *l_malloc (unsigned int size);
       
DESCRIPTION

        Allocated Blocks
       ---------------------
       ||  Size + Status  ||    4 Bytes Lowest Byte is used for Flags
       ---------------------
       ||  User Space     ||    Space available to the calling process
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
       
       
       Size (4 Bytes)
       Size of allocated blocks can be up to a default 100,000 bytes in size 
       change HEAPMAX to a large size to modify the max intial size of the heap 
       located in malloc.asm
       
       Status (LSB) - uses AND operation to determine whether a status flag is
       utilized or not.
       
       00000000 - indicates the block is free
       00000001 - indicates the block is allocated
       
 
 RETURN VALUE
 
       On success, l_malloc() returns a pointer to the reserved block.  On 
       error, NULL is returned.
       
 NOTES
 
       Avoid using brk() and sbrk(): the malloc(3) memory  allocation  package
       is the portable and comfortable way of allocating memory.

       Various  systems  use various types for the argument of sbrk().  Common
       are int, ssize_t, ptrdiff_t, intptr_t.
