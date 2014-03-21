; 14 March 2013
; Assignment 6 malloc3140.asm
; nasm -f elf32 -g malloc3140.asm
; gcc -o main test_malloc_list.c list3140.o malloc3140.o
; to run use ./main

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
	mov edi, [ebp+8]   ;edi contains user requested size
	
	cmp edi, 4   ;checks user input >= 4
	jge .BigEnough
	cmp edi, 0
	je .error
	mov edi, 4
	.BigEnough:
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
	.BestFit:
		cmp ebx, 0		;Is there a prev best fit?
		je .NewBestFit
		mov eax, [ebx]		;Is current location a better
		cmp eax, [esi]  	; fit than prev best fit?
		jge .NewBestFit
		jmp .NextBlock		
		.NewBestFit:
		mov ebx, esi		;make current location best fit
		cmp eax, [esi]
		je .FixHeaders		
	.NextBlock:
		mov eax, [esi]	;Saves Current Block Size in eax
		and eax, 0xFFFFFFFE  ;Mask out the inuse Bit
		add esi, eax 	;CurrentAddress+CurrentBlockSize=NextBlockAdd
		jmp .loop
	
	.GrowHeap:
		mov 	ecx, [HeapStop]
		mov	ebx, ecx
		add	ebx, edi
		mov 	eax, 45
		int	80h
		cmp	eax, 0
		jl	.error
		mov	[HeapStop], eax
		sub	eax, [HeapStart]
		mov 	[HeapSize], eax
		mov     eax, [HeapStart]
		mov 	ebx, ecx
		mov 	[ebx], edi     ;mov req size into ebx
		add dword [ebx], 1     ;tags block as in use
		mov eax, ebx
		jmp .SendPointerToUser	

	.FixHeaders:
		cmp ebx, 0 		;was a best fit found in heap
		je .GrowHeap
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
		int	80h			;checks initial break
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
	jle .error
	cmp [ebp + 12], dword 0  ;checks user input > 0
	jle .error
	
	mov eax, [ebp + 8]
	mov ebx, [ebp + 12]
	imul ebx	;one operand multiplies times eax
	jc .error
	
	;allocate memory for the caller
	push eax
	call l_malloc
	cmp eax, 0
	je .error	;make sure memory was able to be allocated
	pop ebx	;clear previous push off stack
	
	;does some magic to find the length field ...
	sub eax, 4	;now holds length + status
	mov ebx, [eax]	;move header info into ebx
	sub ebx, 1	;remove status flag so ebx has only the size
	add eax, 4	;move eax into allocated blocks of memory
	xor ecx, ecx	;initialize counter
	
		.top:
			mov [eax + ecx * 4], dword 0  ;moves zeros into current mem ptr
			inc ecx			;increment counter
			push eax	;don't erase eax ...
			imul ecx, 4	;make sure we are comparing multiples of 4
			mov edx, eax
			pop eax
			cmp edx, ebx		;check and see if we have gone through allocation
			jl .top		;if not then continue to put zeroes
			jmp .done		;finished!
	
	.error:
	xor eax, eax	;returns NULL on l_calloc() or l_malloc() failure 
	
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
	push ebx
	push edi
	push esi
	
	mov esi, [ebp + 8]	;checks and sees if the *ptr is null
	cmp esi, 0x0	;if *ptr is null just do l_malloc
	je .onNullMalloc	
	
	mov edi, [ebp + 12]	;requested size of the new block of memory
	push edi
	call l_malloc
	pop edi
	cmp eax, 0
	je .error
		mov edi, eax	;save returned pointer
		sub eax, 4
		mov ecx, [eax]
		sub ecx, 1
		
		sub esi, 4	;get to header
		mov eax, [esi] ;realloc *ptr copying size
		sub eax, 1	;remove status flag
		add esi, 4	;restore original *ptr
		
	cmp eax, ecx
		je .ohNoEqual
	cmp eax, ecx
		jl .reallocPtrSmaller
		mov ebx, ecx
		sub ebx, 4
		xor ecx, ecx	;initialize counter
		jmp .top
		
	.ohNoEqual:
		sub eax, 4
		mov ebx, eax
		xor ecx, ecx
		jmp .top
		
	.reallocPtrSmaller:
		mov ebx, eax
		xor ecx, ecx	;initialize counter
	
		.top:
			mov eax, [esi + ecx * 4]
			mov [edi + ecx * 4], eax  ;moves zeros into current mem ptr
			inc ecx			;increment counter
			mov edx, ecx
			imul edx, 4	;make sure we are comparing multiples of 4
			;mov edx, eax
			cmp edx, ebx		;check and see if we have gone through allocation
			jl .top		;if not then continue to put zeroes
			mov eax, edi
			jmp .done		;finished!
	
	.onNullMalloc:
		mov eax, [ebp + 12]	;size requested in l_realloc(null, size)
		push eax
		call l_malloc
		pop ebx
		cmp eax, 0	;was l_malloc() successful?
		je .error
		jmp .done
	
	.error:
	xor eax, eax
	
	.done:
	pop esi
	pop edi
	pop ebx
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
	push edi
	
	mov edi, [ebp + 8]	;*ptr to be freed
	cmp edi, 0x0
	jg .skip
	xor eax, eax
	pop edi
	pop ebx
	mov esp, ebp
	pop ebp
	ret
	
	.skip:
	sub edi, 4		;move ebx to header data
	mov edx, [edi]
	and edx, 0x01
	cmp dl, 0x0
	je .done
	sub [edi], dword 1
	;and dl, 0xFE
	
	;Walks entire stack merging free blocks of until the current location
	mov eax, [HeapStart]
	mov ebx, [HeapStart]
	.mergeFreeBlocks:
		add ebx, [eax]
		cmp ebx, [HeapStop]
		je .done
		mov edx, [eax]
		and edx, 0x01
		cmp dl, 0x0
		je .foundFreeBlock
		mov ecx, [eax]
		sub ecx, 1	;removes the allocated status flag
		add eax, ecx	;moves to next block by adding size - status flag
		jmp .mergeFreeBlocks
	
	;we found one free block so now we check and see if the next block is free
	.foundFreeBlock:
		mov ecx, eax	;copy eax into ecx to find next block
		add ecx, [eax]	;moves to the next block
		mov edx, [ecx]
		and edx, 0x01
		cmp dl, 0x0
		
		;if ebx is allocated go to the next block otherwise add the two sizes
		;together and replace the size field in eax
		jne .go2NextBlock
			cmp ecx, [HeapStop]
			je .done
			mov edx, [ecx]		;moves ebx size value into ecx
			add edx, [eax]		;adds eax size value to edx
			mov [eax], edx		;moves the new size value into eax
			jmp .mergeFreeBlocks
		
		;if the block was not free move the *ptr into eax to update current location
		.go2NextBlock:
			mov edx, [ecx]
			sub edx, 1
			mov eax, ecx	
			jmp .mergeFreeBlocks
	
	.done:
	;check and see if the heap is completely free
	mov ebx, [HeapStart]
	mov eax, [HeapSize]
	cmp [ebx], eax
	jne .out
	.test:
	mov ebx, [HeapStart] ;move the break back prior to the heap creation
	mov eax, 45
	int 0x80
	mov [HeapInit], dword 0	;resets heap init flag
	.out:
	pop edi
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
