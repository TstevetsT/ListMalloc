; nasm -f elf32 -g list3140.asm
; gcc -o main main.c list3140.o malloc3140.o -nostdlib -nodefaultlibs -fno-builtin -nostartfiles


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

;A structure to manage a list of integers, its internal structure
;is opaque to user of the list functions below. In other words
;the layout of this structure is up to you.
;struct _List3140

;A global const that holds the size of a 
;struct _List3140 (ie sizeof(struct _List3140))
;extern const unsigned int List3140Size

size_list:			;used to determine the size of the struc
struc _List3140			;defined structure
	.free:	resb 4		;0 for yes 1 for no
	.prev: resd 1		;*ptr to prev value or null for no nodes
	.value:	resd 1		;integer value
	.next:	resd 1		;*ptr to the next value or null for end
endstruc
List3140Size: equ $ - size_list	;size of the data type


;Allocate AND Initialize a new list
;returns a pointer to the newly allocated list or NULL on error
;struct _List3140 *listNew()
listNew:
	push ebp
	mov ebp, esp
	
	push dword [List3140Size]	;request general size of list
	call l_malloc			;allocate memory for the list
	cmp eax, 0
	je .error			;l_malloc returns null on error
	mov ecx, eax
	
		;initialize list pointer
		push dword 0
		push dword 0
		push dword 0
		push word 0
		push esp
	
	call listInit	;initialize structure to all 0s
	cmp eax, 0
	jle .error
	mov eax, ecx
	mov eax, [_List3140]
	
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
	
	mov eax, [ebp + 8]
	cmp eax, 0
	jle .error
	mov ebx, [eax + _List3140.free]		;initialize free
	mov [_List3140.free], ebx
	mov ebx, [eax + _List3140.prev]		;initialize prev
	mov [_List3140.prev], ebx
	mov ebx, [eax + _List3140.value]	;initialize value
	mov [_List3140.value], ebx
	mov ebx, [eax + _List3140.next]		;initialize next
	mov [_List3140.next], ebx
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
	
	mov eax, [ebp + 8]		;load *list into eax
	push eax			;function iterates through *list until finding head
	call FindHead
	
	.addNode:
		mov ecx, eax		;save eax before calling listNew
		call listNew
		cmp eax, 0
		je .error
			;make the new node the head value
			mov [ecx + _List3140.prev], eax
			;set the previous node to the next value for head
			mov [eax + _List3140.next], ecx
			
			mov ecx, [ebp + 12]			;value passed to this function
			mov [eax + _List3140.value], ecx	;adds value into the newly created head node
			mov [eax + _List3140.free], word 1	;changes free flag to allocated
			mov eax, 1				;returns success
			jmp .done
	
	.error:
	xor eax, eax
	
	.done:
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
	
	mov eax, [ebp + 8]	;moves the *list into eax
	push eax		;function iterates through *list until finding head
	call FindHead
	xor ebx, ebx
	
	.top:
	cmp ebx, [ebp + 12]	;checks index against current location
	je .found
	mov eax, [eax + _List3140.next]	;moves through list until at correct index
	inc ebx
	jmp .top
	
	.found:
	cmp [eax + _List3140.free], word 0
	je .nullFound
	mov [eax + _List3140.free], word 0	;changes free flag to free
	mov ebx, [eax + _List3140.value]	;moves the value at index into ebx
	mov [ebp + 16], ebx			;moves the indexed value into *val
	mov eax, 1				;returns 1 on success
	jmp .done
	
	.nullFound:
	xor eax, eax	;returns 0 on finding NULL
	
	.done:
	pop ebx
	mov esp, ebp
	pop ebp
	ret

;return the size of list
;unsigned int size(struct _List3140 *list)
size:
	push ebp
	mov ebp, esp
	
	mov esp, ebp
	pop ebp
	ret

;clear all data from list. The size of list will be zero
;following this operation
;void clear(struct _List3140 *list)
clear:
	push ebp
	mov ebp, esp
	
	mov esp, ebp
	pop ebp
	ret
	
;int FindHead (struct _List3140 *list)
;returns the head of the list
FindHead:
	push ebp
	mov ebp, esp
	
	mov eax, [ebp + 8]
	cmp [eax + _List3140.prev], dword 0	;if prev is not 0 find the head
	je .done
	mov eax, [eax + _List3140.prev]		;loads new address for previous node
	push eax
	call FindHead
	
	.done:
	mov esp, ebp
	pop ebp
	ret

;int FindTail (struct _List3140 *list)
;returns the tail of the list
FindTail:
	push ebp
	mov ebp, esp
	
	mov eax, [ebp + 8]
	cmp [eax + _List3140.next], dword 0	;if prev is not 0 find the head
	je .done
	mov eax, [eax + _List3140.next]		;loads new address for previous node
	push eax
	call FindTail
	
	.done:
	mov esp, ebp
	pop ebp
	ret

;Initialized Data
section .data
 
;Uninitialized Data 
section .bss
