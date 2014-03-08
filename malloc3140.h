
#ifndef __MALLOC_3140_H
#define __MALLOC_3140_H

//allocate a block of memory capable of holding size
//bytes of user specified data. If size is zero, a pointer
//to zero bytes of memory should be returned
//returns NULL on failure or pointer to new block on success
void *l_malloc(unsigned int size);

//allocate a contiguous block of memory capable of
//holding nmemb * size bytes of user specified data. If
//nmemb or size are zero, a pointer to zero bytes of
//memory should be returned.
//The resulting block of memory will be filled with zero
//returns NULL on failure or pointer to new block on success
void *l_calloc(unsigned int nmemb, unsigned int size);

//Reallocate a block of memory pointed to by ptr. The contents
//of the original memory block are copied to the new memory
//block. Note that the new size may be larger, smaller, or the
//same as the current size. If the new memory allocation is
//successful, the original block of memory will be free'd. 
//If ptr is NULL this function effectively becomes malloc(size)
//returns NULL on failure or pointer to new block on success
void *l_realloc(void *ptr, unsigned int size);

//release the memory pointed to by ptr. ptr may be NULL in which
//case no action is taken.
void l_free(void *ptr);

#endif

