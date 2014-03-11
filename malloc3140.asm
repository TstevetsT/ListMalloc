; 14 March 2013
; Assignment 6 malloc3140.asm

; nasm -f elf32 -g malloc3140.asm
; gcc -o main main.c list3140.o malloc3140.o -nostdlib -nodefaultlibs -fno-builtin -nostartfiles

BITS 32					; USE32

global l_malloc		;void *l_malloc(unsigned int size)
global l_calloc		;void *l_calloc(unsigned int nmemb, unsigned int size)
global l_realloc	;void *l_realloc(void *ptr, unsigned int size)
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
	push edi
	push esi
	
	cmp [ebp + 8], dword 4   ;checks user input >= 4
	jge .error
	cmp byte [Heap.InitFlag], 0   ;Check if heap is created
	jne .skipCreateHeap
	call .CreateHeap         ;Heap created eax=start address=Heap.Start
	
	.skipCreateHeap:	;    ebx=first address after break=Heap.Stop
	mov edi, [ebp + 8]	;Holds User Requested size
	add edi, 4		;adds header space to user size
	mov esi, [Heap.Start]	;CurrentAddress
	;mov ebx,  		************************** not sure what's missing here?
	.loop:
		mov eax, [Heap.Stop]
		sub eax, 4		;Ensures last 4 bytes are not allocated
		cmp esi, eax
		jge .error
		
	;FindFreeBlock
		mov eax, [esi]
		and eax, 0x01
		cmp eax, 0
		jne .NextBlock
		
	;BlockBigEnough
		cmp [esi], edi
		jl .NextBlock
	;BestFit
		
	;FixHeaders
	.NextBlock:
		mov eax, [esi]	;Saves Current Block Size in eax
		and eax, 0xFE	;Masks Out the In Use Bit
		add esi, eax 	;CurrentAddress+CurrentBlockSize=NextBlockAdd
		jmp .loop
 	
	;ensure eax holds pointer to user block
	pop esi
	pop edi
	pop ebx
	mov esp, ebp
	pop ebp
	ret

	.error:
		xor eax, eax
		pop esi
		pop edi
		pop ebx
		mov esp, ebp
		pop ebp
		ret

	.CreateHeap:
		mov	eax, 45			;sys_brk
		int	80h			;sets initial break pointer to start in eax
		cmp	eax, 0
		jl	.error			;exit, if error
		mov 	[Heap.Start], eax
		xor  	ebx, ebx
		add	ebx, HEAPMAX		;number of bytes to be reserved
		mov 	[Heap.Size], ebx
		mov	eax, 45			;sys_brk
		int	80h			;sets final break 	
		cmp	eax, 0
		jl	.error	;exit, if error 
		mov 	[Heap.Stop], eax
		mov 	eax, [Heap.Start] 	
		add 	ebx, 1
		mov 	[eax], ebx		;initializes the first header
		mov byte [Heap.InitFlag], 1	;Sets heap as initialized
		ret


;allocate a contiguous block of memory capable of
;holding nmemb * size bytes of user specified data. If
;nmemb or size are zero, a pointer to zero bytes of
;memory should be returned.
;The resulting block of memory will be filled with zero
;returns NULL on failure or pointer to new block on success
;void *l_calloc(unsigned int nmemb, unsigned int size)
l_calloc:

	push ebp		 ;preserve no clobber register
	mov ebp, esp
	push ebx		 ;preserve no clobber register
	
	xor eax, eax
	
	cmp [ebp + 8], dword 0   ;checks user input > 0
	jg .intNmemb
	cmp [ebp + 12], dword 0  ;checks user input > 0
	jg .intSize
	jmp .done		 ;returns NULL on faliure or 0
	
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
			inc ecx				;increment counter
			cmp ecx, ebx			;check and see if we have gone through allocation
			jl .sizeTop			;if not then continue to put zeroes
			pop eax				;restore memory address ptr
			jmp .done			;finished!
	
	.intNmemb:
	push dword [ebp + 8]	;uses int nmemb to allocate a block of memory
	call l_malloc 		;call l_malloc before zeroizing
	cmp eax, 0		;checks for error
	je .error
	push eax		;preserve memory address ptr
	xor ecx, ecx		;initialize counter to 0
	mov ebx, [ebp + 8]  	;moves the size requested into ebx
	
		.nmembTop:
			mov [eax * 4 + ecx], dword 0  ;moves zeros into current mem ptr
			inc ecx			;increment counter
			cmp ecx, ebx		;check and see if we have gone through allocation
			jl .nmembTop		;if not then continue to put zeroes
			pop eax			;restore memory address ptr
			jmp .done		;finished!
	
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
	push ebx
	
	mov eax, [Heap.Start]	;beginning of the heap
	mov ecx, [ebp + 8]	;*ptr to be freed
	sub ecx, 4		;move ebx to header data
	and cl, 0xFE		;sets the LSB to 0
	
	;Walks entire stack merging free blocks
	.mergeFreeBlocks:
	cmp eax, [Heap.Start + Heap.Size]
	jge .done
	add ebx, [eax-1]	;moves to next block by adding size - status
	movzx ecx, byte [eax]	;moves lowest byte into cl
	and cl, 0x01		;masks out all the size bits and leaves free/used flag
	cmp cl, 0		;is the current block free?
	je .foundFreeBlock
	
	;if the block was not free move the *ptr into eax
	mov eax, ebx	
	jmp .mergeFreeBlocks
	
	;eax was free so now we check and see if ebx is free
	.foundFreeBlock:
		movzx ecx, byte [ebx]	;moves lowest byte into cl
		and cl, 0x01  		;masks out all the size bits and leaves free/used flag
		cmp cl, 0		;is the current block free?
		
		;if ebx is allocated go to the next block otherwise add the two sizes
		;together and replace the size field in eax
		jne .go2NextBlock
			mov ecx, [ebx]		;moves ebx size value into ecx
			mov edx, [eax]		;moves eax size value into edx
			add ecx, edx		;adds both sizes together
			mov [eax], ecx		;moves the new size value into eax
			jmp .mergeFreeBlocks
		
		;if the block was not free move the *ptr into eax
		.go2NextBlock:
			mov eax, ebx	
			jmp .mergeFreeBlocks
	
	.done:
	pop ebx
	mov esp, ebp
	pop ebp
	ret

	
section .data
struc Heap
	.Start:	RESD 1   	;Heap Start Address
	.Stop: RESD 1		;First Address After Heap
	.Size: RESD 1		;Heap Size
	.InitFlag: RESB 1 	;Flag indicates whether a heap has been created
endstruc

section .rodata
HEAPMAX dd 0x186A0	
