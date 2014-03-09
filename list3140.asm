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

;Macros Defined:
%define usedNode 	mov byte [eax + _List3140.free], 0x1	;sets the free flag to no
%define freeNode 	mov byte [eax + _List3140.free], 0x0	;sets the free flag to yes
%define setValue	mov [eax + _List3140.data], ebx		;places a value into node
%define setNxtNode	mov [eax + _List3140.next], ebx		;points to next node in list
%define setNewNode	mov ebx, [ebx + _List3140.next]		;value of the next node in ebx

;A structure to manage a list of integers, its internal structure
;is opaque to user of the list functions below. In other words
;the layout of this structure is up to you.
;struct _List3140

;A global const that holds the size of a 
;struct _List3140 (ie sizeof(struct _List3140))
;extern const unsigned int List3140Size

size_list:			;used to determine the size of the struc
struc _List3140			;defined structure
	.free:	resb 1		;0 for yes 1 for no
	.data:	resd 1		;integer value
	.next:	resd 1		;* to the next value or null for end
endstruc
List3140Size: equ $ - size_list	;size of the data type


;Allocate AND Initialize a new list
;returns a pointer to the newly allocated list or NULL on error
;struct _List3140 *listNew()
listNew:
	push ebp
	mov ebp, esp
	
	mov esp, ebp
	pop ebp
	ret

;Initialize the list structure pointed to by list
;returns 0 on failure, 1 on success
;int listInit(struct _List3140 *list)
listInit:
	push ebp
	mov ebp, esp
	
	mov esp, ebp
	pop ebp
	ret

;Add val at the head of list
;returns 0 on failure, 1 on success
;int addHead(struct _List3140 *list, int val)
addHead:
	push ebp
	mov ebp, esp
	
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
	
	xor eax, eax
	mov ebx, [ebp + 8]	;moves the *list into ebx
	
	.top:
	cmp eax, [ebp + 12]	;checks index against current location
	je .found
	mov ebx, [ebx + _List3140.next]	;moves through list until at correct index
	inc eax
	jmp .top
	
	.found:
	cmp [ebx + _List3140.data], dword 0x0  ;is data > 0?
	je .nullFound
	freeNode	;sets the free flag to yes
	mov eax, [ebx + _List3140.data]
	mov [ebp + 16], eax	;moves the value into *val
	mov eax, 1	;returns 1 on success
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

;Initialized Data
section .data
 
nonodes equ     0x100           ; max number of nodes
onens   equ     0x8             ; space per node (_one_ _n_ode _s_pace)
maxnode equ     nodesp+((nonodes-1) * onens)+1
lista   dd      0x0             ; pointer to list a
listb   dd      0x0             ; pointer to list b
 
;Uninitialized Data 
section .bss

nodesp: resd    nonodes*3   ; reserve space for the nodes
tempa:  resd    1
tempb:  resd    1
tempc:  resd    1
tempn:  resd    1
list1:  resd    1
list2:  resd    1
