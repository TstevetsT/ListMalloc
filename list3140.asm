; nasm -f elf32 -g list3140.asm
; gcc -o main main.c list3140.o malloc3140.o -nostdlib -nodefaultlibs -fno-builtin -nostartfiles
;test commit I am changing here to test


BITS 32					; USE32

global listNew	;struct _List3140 *listNew()
global listInit		;int listInit(struct _List3140 *list)
global addHead		;int addHead(struct _List3140 *list, int val)
global removeHead		;int removeHead(struct _List3140 *list, int *val)
global addTail		;int addTail(struct _List3140 *list, int val)
global removeTail		;int removeTail(struct _List3140 *list, int *val)
global itemAt		;int itemAt(struct _List3140 *list, unsigned int n, int *val)
global removeItem		;int removeItem(struct _List3140 *list, unsigned int n, int *val)
global size		;unsigned int size(struct _List3140 *list)
global clear		;void clear(struct _List3140 *list)

;A structure to manage a list of integers, its internal structure
;is opaque to user of the list functions below. In other words
;the layout of this structure is up to you.
struct _List3140

;A global const that holds the size of a 
;struct _List3140 (ie sizeof(struct _List3140))
extern const unsigned int List3140Size


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
