; nasm -f elf32 -g list3140.asm
; gcc -o main list.c list3140.o malloc3140.o -nostdlib -nodefaultlibs -fno-builtin -nostartfiles


BITS 32			; USE32

global listNew		;struct _List3140 *listNew()
global listInit		;int listInit(struct _List3140 *list)
global addHead		;int addHead(struct _List3140 *list, int val)
global removeHead	;int removeHead(struct _List3140 *list, int *val)
global addTail		;int addTail(struct _List3140 *list, int val)
global removeTail	;int removeTail(struct _List3140 *list, int *val)
global itemAt		;int itemAt(struct _List3140 *list, unsigned int n, int *val)
global removeItem	;int removeItem(struct _List3140 *list, unsigned int n, int *val)
global size		;unsigned int size(struct _List3140 *list)
global clear		;void clear(struct _List3140 *list)

extern l_malloc		;void *l_malloc(unsigned int size)
extern l_free ;void l_free(void *ptr)

;A structure to manage a list of integers, its internal structure
;is opaque to user of the list functions below. In other words
;the layout of this structure is up to you.
;struct _List3140

struc _List3140			;defined structure
	.prev: resd 1		;*ptr to prev value or null for no nodes
	.value:	resd 1		;integer value
	.next:	resd 1		;*ptr to the next value or null for end
endstruc

;A global const that holds the size of a 
;struct _List3140 (ie sizeof(struct _List3140))
;extern const unsigned int List3140Size

global List3140Size 
List3140Size equ _List3140_size

;Allocate AND Initialize a new list
;returns a pointer to the newly allocated list or NULL on error
;struct _List3140 *listNew()
listNew:
	push ebp
	mov ebp, esp
	
	push dword List3140Size ;request general size of list
	call l_malloc			;allocate memory for the list
	cmp eax, 0
	je .error			;l_malloc returns null on error
	
	push eax	;push pointer to memory address that was malloc'd
	call listInit	;initialize structure to all 0s
	cmp eax, 0
	je .error
	pop eax
	
	.error:
	mov esp, ebp
	pop ebp
	ret

;Initialize the list structure pointed to by list
;returns 0 on failure, 1 on success
;int listInit(struct _List3140 *list)
listInit:
	push ebp
	mov ebp, esp
	push ebx
	xor ebx, ebx
	
	mov eax, [ebp + 8]
	cmp eax, 0
	jle .error
	mov [eax + _List3140.prev], ebx		;initialize prev with null
	mov [eax + _List3140.value], ebx	;initialize value with null
	mov [eax + _List3140.next], ebx		;initialize next with null
	mov eax, 1
	
	.error:
	pop ebx
	mov esp, ebp
	pop ebp
	ret

;Add val at the head of list
;returns 0 on failure, 1 on success
;int addHead(struct _List3140 *list, int val)
addHead:
	push ebp
	mov ebp, esp
	push ebx
	push edi
	
	mov ebx, [ebp + 8]	;loads the *list into ebx
	mov edi, [ebx + _List3140.prev]	;loads head
	
	;check and see if this is the first node
	;if the value is null that means there is no head
	cmp edi, dword 0
	jne .addNode
	.noHead:
		;mov eax, [ebp + 8]	;load *list into eax
			call listNew	;creates a new node
			cmp eax, 0
			je .error
			;sets up second node and head/tail of the admin node (first node)
			mov [ebx + _List3140.prev], eax
			mov [ebx + _List3140.next], eax
			mov [eax + _List3140.prev], eax
			mov [eax + _List3140.next], eax
			
			mov ecx, [ebp + 12]			;value passed to this function
			mov [eax + _List3140.value], ecx	;adds value into the newly created head node
			add [ebx + _List3140.value], dword 1 ;number of nodes inserted increases
			mov eax, 1
			jmp .done
	
	.addNode:
		call listNew	;creates a new node
		cmp eax, 0
		je .error
			mov ecx, [edi + _List3140.prev]	;loads current head
			mov [edi + _List3140.prev], eax	;links old head to new head
			mov [eax + _List3140.prev], eax	;set new node as head
			mov [eax + _List3140.next], ecx	;set old head as next node in list
			mov [ebx + _List3140.prev], eax	;set new node as top of list
			
		.addValue:
			mov ecx, [ebp + 12]			;value passed to this function
			mov [eax + _List3140.value], ecx	;adds value into the newly created head node
			add [ebx + _List3140.value], dword 1 ;number of nodes inserted increases
			mov eax, 1				;returns success
			jmp .done
	
	.error:
	xor eax, eax
	
	.done:
	pop edi
	pop ebx
	mov esp, ebp
	pop ebp
	ret

;Remove the integer at the head of the list returning
;the value of that integer in *val (if val is not NULL)
;returns 0 on failure, 1 on success
;int removeHead(struct _List3140 *list, int *val)
removeHead:
	push ebp
	mov ebp, esp
	push ebx
	push edi
	
	cmp [ebp + 12], dword 0	;check for null value in arg [2]
	je .nullFound
	
	mov ebx, [ebp + 8]	;loads the *list into ebx
	mov eax, [ebx + _List3140.prev]	;loads head

	;moves the value at index into ebx and then into arg [2]
	mov ebx, [eax + _List3140.value]
	mov [ebp + 12], ebx

	;is there no tail? is so just free the node
	cmp [eax + _List3140.next], eax
	je .free

	;does some cleanup of the list to make sure the links still connect
	.cleanup:
		mov ebx, [ebp + 8]	;admin node with head/tail/count
		mov edi, [eax + _List3140.next]	;node right below head
		mov [ebx + _List3140.prev], edi	;sets new head
		mov [edi + _List3140.prev], edi ;sets node to head
		;mov [ebx + _List3140.prev], edi
		;mov eax, [edi + _List3140.next]
		;mov [edi + _List3140.next], ebx
		
	.free:
		mov [eax + _List3140.next], dword 0	;only for testing
		mov [eax + _List3140.prev], dword 0	;only for testing
		mov [eax + _List3140.value], dword 0	;only for testing
		push ebx
		call l_free
		mov eax, 1	;returns 1 on success
		mov edi, [ebp + 8]
		sub [edi + _List3140.value], dword 1
		jmp .done
	
	.nullFound:
		xor eax, eax	;returns 0 on finding NULL
	
	.done:
	pop edi
	pop ebx
	mov esp, ebp
	pop ebp
	ret

;return the size of list
;unsigned int size(struct _List3140 *list)
size:
	push ebp
	mov ebp, esp
	
	lea eax, [HOT]
	mov eax, [eax + _HeadsOrTails.size]
	
	mov esp, ebp
	pop ebp
	ret

;Add val at the tail of list
;returns 0 on failure, 1 on success
;int addTail(struct _List3140 *list, int val)
addTail:
	push ebp
	mov ebp, esp
	push ebx
	
	
	pop ebx
	mov esp, ebp
	pop ebp
	ret

;Remove the integer at the tail of the list returning
;the value of that integer in *val (if val is not NULL)
;returns 0 on failure, 1 on success
;int removeTail(struct _List3140 *list, int *val)
removeTail:
	push ebp
	mov ebp, esp
	push ebx
	
	
	pop ebx
	mov esp, ebp
	pop ebp
	ret

;Retrieve the integer at index n of the list returning
;the value of that integer in *val (if val is not NULL)
;returns 0 on failure, 1 on success
;int itemAt(struct _List3140 *list, unsigned int n, int *val)
itemAt:
	push ebp
	mov ebp, esp
	
	mov esp, ebp
	pop ebp
	ret

;Remove the integer at index n of the list returning
;the value of that integer in *val (if val is not NULL)
;returns 0 on failure, 1 on success
;int removeItem(struct _List3140 *list, unsigned int n, int *val)
removeItem:
	push ebp
	mov ebp, esp
	push ebx
	push edi
	push esi
	
	cmp [ebp + 16], dword 0			;check for null value in third arg
	je .nullFound
	
	mov ebx, [ebp + 8]				;heads or tails struc
	mov edi, [ebx + _List3140.value]
	cmp edi, dword 1			;is there only one node? if so just free it
	jle .free
	
	;starts from the tail of the list and moves forward
	mov eax, [ebx + _List3140.next]
	xor ebx, ebx
	
	.tailSearch:
		cmp ebx, [ebp + 12]		;checks index against current location
		je .cleanup
		mov eax, [eax + _List3140.prev]	;moves through list until at correct index
		inc ebx
		jmp .tailSearch
	
	;does some cleanup of the list to make sure the links still connect
	.cleanup:
		mov edi, [eax + _List3140.prev]
		mov esi, [eax + _List3140.next]
		mov [edi + _List3140.next], esi
		mov [esi + _List3140.prev], edi
		
	.free:
		mov ebx, [eax + _List3140.value]	;moves the value at index into ebx
		mov [ebp + 16], ebx			;moves the indexed value into *val
		mov [eax + _List3140.next], dword 0	;only for testing
		mov [eax + _List3140.prev], dword 0	;only for testing
		mov [eax + _List3140.value], dword 0	;only for testing
		push eax
		call l_free
		lea edi, [HOT]
		sub [edi + _HeadsOrTails.size], dword 1
		mov eax, 1	;returns 1 on success
		jmp .done
	
	.nullFound:
		xor eax, eax	;returns 0 on finding NULL
	
	.done:
	pop esi
	pop edi
	pop ebx
	mov esp, ebp
	pop ebp
	ret

;clear all data from list. The size of list will be zero
;following this operation
;void clear(struct _List3140 *list)
clear:
	push ebp
	mov ebp, esp
	
	lea eax, [HOT]	;start clearing from head
	mov eax, [eax + _HeadsOrTails.head]
	
	;routine to delete nodes and move onto the next node
	.clearNodes:
		cmp [eax + _List3140.next], dword 0
		je .done
		mov ecx, [eax + _List3140.next]
		push eax
		call l_free
		mov eax, ecx
		jmp .clearNodes
	
	;zeroizes the last node and head/tail
	.done:
		push eax
		call listInit
		lea eax, [HOT]
		mov [eax + _HeadsOrTails.size], dword 0
		mov [eax + _HeadsOrTails.head], dword 0
		mov [eax + _HeadsOrTails.tail], dword 0
	
	mov esp, ebp
	pop ebp
	ret

;Initialized Data
section .data
 
;Uninitialized Data 
section .bss
HOT:
struc _HeadsOrTails
	.size: resd 1		;holds the number of nodes in the list
	.head: resd 1		;holds the head of the list
	.tail: resd 1		;holds the tail of the list
endstruc
