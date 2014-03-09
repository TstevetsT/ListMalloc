; 14 March 2013
; Assignment 6 malloc3140.asm

; nasm -f elf32 -g malloc3140.asm
; gcc -o main main.c list3140.o malloc3140.o -nostdlib -nodefaultlibs -fno-builtin -nostartfiles

BITS 32					; USE32

global l_malloc		;void *l_malloc(unsigned int size)
global l_calloc		;void *l_calloc(unsigned int nmemb, unsigned int size)
global l_realloc		;void *l_realloc(void *ptr, unsigned int size)
global l_free		;void l_free(void *ptr)

;allocate a block of memory capable of holding size
;bytes of user specified data. If size is zero, a pointer
;to zero bytes of memory should be returned
;returns NULL on failure or pointer to new block on success
;void *l_malloc(unsigned int size)
l_malloc:
	push ebp
	mov ebp, esp
	push ebx
	
	cmp [BrkInfo.InitFlag], 0
	jne .skipCreateHeap
	mov [BrkInfo.InitFlag], 1
	
	mov	eax, 45		;sys_brk
	xor	ebx, ebx
	int	80h		;sets initial break
	cmp	eax, 0
	jl	.error	;exit, if error
	push eax		;push starting location for heap
	
	add	ebx, HEAPMAX	;number of bytes to be reserved
	mov	eax, 45		;sys_brk
	int	80h		;sets final break	
	cmp	eax, 0
	jl	.error	;exit, if error 
	
	pop eax
	;logic for setting header for break
	;create a function for this maybe?
	
	
	pop ebx
	mov esp, ebp
	pop ebp
	ret
	
	.error:
	xor eax, eax
	pop ebx
	pop edi
	mov esp, ebp
	pop ebp
	ret
	
	.skipCreateHeap:
	;logic for making changes to an already intialized heap
	;create a function for this maybe?
	
	ret

;allocate a contiguous block of memory capable of
;holding nmemb * size bytes of user specified data. If
;nmemb or size are zero, a pointer to zero bytes of
;memory should be returned.
;The resulting block of memory will be filled with zero
;returns NULL on failure or pointer to new block on success
;void *l_calloc(unsigned int nmemb, unsigned int size)
l_calloc:
	push ebp
	mov ebp, esp
	
	mov esp, ebp
	pop ebp
	ret

;Reallocate a block of memory pointed to by ptr. The contents
;of the original memory block are copied to the new memory
;block. Note that the new size may be larger, smaller, or the
;same as the current size. If the new memory allocation is
;successful, the original block of memory will be free'd. 
;If ptr is NULL this function effectively becomes malloc(size)
;returns NULL on failure or pointer to new block on success
;void *l_realloc(void *ptr, unsigned int size)
l_realloc:
	push ebp
	mov ebp, esp
	
	mov esp, ebp
	pop ebp
	ret

;release the memory pointed to by ptr. ptr may be NULL in which
;case no action is taken.
;void l_free(void *ptr)
l_free:
	push ebp
	mov ebp, esp
	
	mov esp, ebp
	pop ebp
	ret
	
section .data
struc BrkInfo
	.Init:	RESB 1
endstruc

section .rodata
HEAPMAX dd 0x186A0	