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
	
	cmp byte [BrkInfo.InitFlag], 0
	jne .skipCreateHeap
	mov byte [BrkInfo.InitFlag], 1
	
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

push ebp	;preserve no clobber register
mov ebp, esp
push ebx	;preserve no clobber register
	
xor eax, eax
	
cmp [ebp + 12], dword 0  ;checks user input > 0
jg .intSize
cmp [ebp + 8], dword 0   ;checks user input > 0
jg .intNmemb
jmp .done	;returns NULL on faliure or 0
	
.intSize:
	push dword [ebp + 12]	;uses int size to allocate a block of memory
	call l_malloc	;call l_malloc before zeroizing
	cmp eax, 0	;checks for error
	je .error
	push eax	;preserve memory address ptr
	xor ecx, ecx	;initialize counter to 0
	mov ebx, [ebp + 12]  ;moves the size requested into ebx
	
	.sizeTop:
		mov [eax * 4 + ecx], dword 0  ;moves zeros into current mem ptr
		inc ecx		;increment counter
		cmp ecx, ebx	;check and see if we have gone through allocation
		jl .sizeTop	;if not then continue to put zeroes
		pop eax		;restore memory address ptr
		jmp .done	;finished!
	
.intNmemb:
	push dword [ebp + 8]	;uses int nmemb to allocate a block of memory
	call l_malloc 	;call l_malloc before zeroizing
	cmp eax, 0	;checks for error
	je .error
	push eax	;preserve memory address ptr
	xor ecx, ecx	;initialize counter to 0
	mov ebx, [ebp + 8]  ;moves the size requested into ebx
	
	.nmembTop:
		mov [eax * 4 + ecx], dword 0  ;moves zeros into current mem ptr
		inc ecx		;increment counter
		cmp ecx, ebx	;check and see if we have gone through allocation
		jl .nmembTop	;if not then continue to put zeroes
		pop eax		;restore memory address ptr
		jmp .done	;finished!
	
.error:
	xor eax, eax	;returns NULL on l_calloc() failure 
	
.done:
	pop ebx		;restore no clobber register
	mov esp, ebp
	pop ebp		;restore no clobber register
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
	.InitFlag:	RESB 1
endstruc

section .rodata
HEAPMAX dd 0x186A0	
