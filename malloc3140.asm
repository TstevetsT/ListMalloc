; 14 March 2013
; Assignment 6 malloc3140.asm
;; nasm -f elf32 -g malloc3140.asm
; gcc -o main main.c list3140.o malloc3140.o -nostdlib -nodefaultlibs -fno-builtin -nostartfiles

BITS 32					; USE32

global l_malloc		;void *l_malloc(unsigned int size)
global l_calloc	;void *l_calloc(unsigned int nmemb, unsigned int size)
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
	mov edi, [ebp+8]
	cmp edi, 4   ;checks user input >= 4
	jl .error
	cmp byte [HeapInit], 0	   	;Check if heap is created
	jne .skipCreateHeap
	call .CreateHeap 
	.skipCreateHeap:	
	add edi, 4		;adds header space to requested user size
	mov eax, edi		
	and eax, 0x03		;mask out last two bits
	cmp eax, 0		;do they have a value?
	je .MultipleOfFour
	mov eax, edi		
	and eax, 0xFFFFFFFC		;mask out last two bits
	add eax, 4		;add 4
	mov edi, eax		;replace in edi
	.MultipleOfFour:
	mov esi, [HeapStart]	;CurrentAddress
	mov ebx, 0		;BestFit Address 0=No fit found
	.loop:
		mov eax, [HeapStop]
		sub eax, 4	;Ensures last 4 bytes are not allocated
		cmp esi, eax
		jg .FixHeaders
		
	;FindFreeBlock
		mov eax, [esi]
		and eax, 0x01
		cmp eax, 0
		jne .NextBlock
		
	;BlockBigEnough
		cmp [esi], edi
		jl .NextBlock
	;BestFit
		cmp ebx, 0		;Is there a prev best fit?
		je .NewBestFit
		mov eax, [ebx]		;Is current location a better
		cmp eax, [esi]  	; fit than prev best fit?
		jl .NewBestFit
		jmp .NextBlock		
		.NewBestFit:		
		mov ebx, esi		;make current location best fit
		jmp .NextBlock

	.FixHeaders:
		cmp ebx, 0 		;was a best fit found in heap
		je .error
		mov eax, [ebx]
;What is This	add eax, 8	;If current block size is <= 8 bytes 
				;	bigger than required block size
		cmp eax, edi		;compare cur size + 8 to req siz
		jle .KeepBlockSize	;Keep block size
		mov eax, ebx
		mov ecx, [eax]		;copy old current block size
		add eax, edi 		;create new header for next blk
		sub ecx, edi		;Calculate remaining block size
		mov [eax], ecx		;Fills header for trailing block
		mov dword [ebx], edi	;moves req size into user header
		.KeepBlockSize:
			add dword [ebx], 1	;tags user block as in use
			mov eax, ebx
			jmp .SendPointerToUser
	.NextBlock:
		mov eax, [esi]	;Saves Current Block Size in eax
		and eax, 0xFFFFFFFE  ;Mask out the inuse Bit
		add esi, eax 	;CurrentAddress+CurrentBlockSize=NextBlockAdd
		jmp .loop
		
	.SendPointerToUser:
		add eax, 4	;adjusts eax so it holds users pointer
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
		xor  	ebx, ebx
		mov	eax, 45			;sys_brk
		int	80h			;sets initial break
		cmp	eax, 0
		jl	.error			;exit, if error
		mov	[HeapStart], eax
		mov 	ebx, [HEAPMAX]
		add	ebx, eax
		mov 	eax, 45
		int	80h
		mov	[HeapStop], eax
		cmp	eax, 0
		jl	.error
		sub	eax, [HeapStart]
		mov 	[HeapSize], eax
		mov byte	[HeapInit], 1
		mov     eax, [HeapStart]
		mov  	ebx, [HeapSize]
		mov 	[eax], ebx
		.test: 
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
	
	mov eax, [HeapStart]	;beginning of the heap
	mov ecx, [ebp + 8]	;*ptr to be freed
	sub ecx, 4		;move ebx to header data
	and cl, 0xFE		;sets the LSB to 0
	
	;Walks entire stack merging free blocks
	.mergeFreeBlocks:
	mov ebx, [HeapStart]
	add ebx, [HeapSize]
	cmp eax, ebx
	jge .done
	add ebx, [eax]	;moves to next block by adding size - status
	sub dword [ebx], 1
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

HeapStart dd 0   	;Heap Start Address
HeapStop dd 0		;First Address After Heap
HeapSize dd 0		;Heap Size
HeapInit db 0		;Flag indicates whether a heap has been created

section .rodata
HEAPMAX dd 0xFA0	
