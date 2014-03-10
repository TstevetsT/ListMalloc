MALLOC(2)                     Linux Programmer's Manual                    MALLOC(2)

NAME

       l_malloc

SYNOPSIS

       void *l_malloc (unsigned int size);
       
DESCRIPTION

              Blocks
       ---------------------    <-- Memory Ptr of Header
       ||  Size + Status  ||    4 Bytes Lowest bit is used for flag
       ---------------------    <-- Memory Ptr Addr Returned
       ||  Free Space     ||    Space available to the calling process
       ---------------------
       
       Allocated block headers are 4 bytes in size. The minimum block
       allocation is 4 bytes. With no space for user data. This will keep 
       free blocks aligned in the heap. If any blocks are 4 bytes in size
       it will automatically be added to the allocation.
       
       Size (4 Bytes)
       Size of allocated blocks can be up to a default 100,000 bytes in size 
       change HEAPMAX to a large size to modify the max intial size of the heap 
       located in malloc.asm
       
       Status (LSB) - uses AND operation to determine whether a status flag is
       utilized or not.
       
       00000000 - indicates the block is free
       00000001 - indicates the block is allocated
       
       When a block of memory is freed the entire heap will be checked for blocks
       to coalesce due to the absence of a previous pointer and next pointer within
       the header information for a given block.
       
 
 RETURN VALUE
 
       On success, l_malloc() returns a pointer to the reserved block.  On 
       error, NULL is returned.
       
 NOTES
 
       The priority for malloc is ensuring the maximum amount of space available
       for the calling process/function.  Usable space has more priority than
       speed, and this resulted in a smaller header but more overhead to process
       changes to the heap during coalescence (consolidating free space).