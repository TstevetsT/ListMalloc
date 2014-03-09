;;; Linked lists; my first not entirely trivial assembler program
;;; 
;;; Bart Kastermans, www.bartk.nl
 
section .text
        global  main            ; gcc likes main, ld linkes _start
                                ; but can use ld -e main
                                ; with gcc get linkage for printf
 
;;; Use printf from libraries
extern printf
 
;;; Macros for manipulating a node with address in eax, values in ebx
%define usenode    mov      word [eax+node.used],0x1
%define freenode   mov      word [eax+node.used],0x0
%define setnodev   mov      [eax+node.value],bx
%define setnodel   mov      [eax+node.next],ebx
%define ebxnn      mov      ebx,[ebx+node.next]
         
;;; Test newnode and printl
testnn: call    newnode
        mov     bx, 0x5
        setnodev
        mov     [tempn],eax
        call    newnode
        mov     bx,0x2
        setnodev
        mov     ebx,[tempn]
        setnodel
        mov     ebx,eax
         
        call    printl
        ret
         
;;; Test newlist, addlist, and printl
testnl: mov     bx,0x1
        call    newlist
        mov     [list1],eax
        mov     bx,0x2
        call    addlist
        mov     eax,[list1]
        mov     bx,0x3
        call    addlist
        mov     eax,[list1]
        mov     bx,0x4
        call    addlist
 
        mov     ebx,[list1]
 
        call    printl
        ret
 
;;; Test running out of space for nodes.
;;; Note that when other tests are run before we'll run out before 0x101
testos: mov     edx,0x101       ; plan to assign 0x101 nodes
        mov     ebx,edx
        call    newlist
        mov     [list1],eax     ; set up new list head in [list1]
.nn:    sub     edx,0x1
        mov     ebx,edx
        mov     eax,[list1]
        call    addlist
        cmp     edx,0x0
        jne     .nn
        ret
         
main:   mov     edx,0x5
        call    seqlist
        mov     [tempa],eax
        mov     ebx,[tempa]
        call    printl
        mov     ebx,[tempa]
        ebxnn
        ebxnn
        call    delnode         ; deleting the node after 3rd node
        mov     ebx,[tempa]
        call    printl
        mov     ebx,[tempa]
        ebxnn
        ebxnn
        mov     ax,0x9
        call    insnode
        mov     ebx,[tempa]
        call    printl
         
retsuc: mov     ebx,0           ; return value, succes
        mov     eax,1           ; kernel function to exit program
        int     0x80            ; exit program
 
retfa:  mov     ebx,1           ; return on fail
        mov     eax,1
        int     0x80
         
;;; Linked list
;;; In this first attempt just allocate the list and print it 
 
struc node
        .used   resw    1
        .value  resw    1
        .next   resd    1
endstruc
 
         
 
;;; Put in eax the address of next available node
newnode:
        mov     eax,nodesp      ; put nodespace address in eax
.nn:    cmp     eax,maxnode
        jae     nospace         ; no node can start above maxnode
        cmp     dword [eax+node.used],0x0 ; check if available
        je      .nodefound
        add     eax,onens       ; move to next node
        jmp     .nn
.nodefound:
        usenode
        ret
 
;;; Put in eax the address of a new list with value as in ebx
newlist:
        call    newnode
        setnodev
        ret
 
;;; Add value in ebx to end of list in eax
addlist:
        cmp     dword [eax+node.next],0x0
        je      .attail       ; eax now contains the last node in list
        mov     eax,[eax+node.next]
        jmp     addlist
 
.attail:
        mov     ecx,eax         ; save tail node to set .next on it later
        call    newnode         ; get new node
        setnodev                ; set value of new node
        mov     [ecx+node.next],eax ; point previous tail to this new node
        ret
 
;;; Build a list with edx..0 in the nodes (call with edx>0)
seqlist:
        mov     ebx,edx
        call    newlist
        mov     [tempa],eax
.nn:    sub     edx,0x1
        cmp     edx,0x0
        jbe      .done
        mov     eax,[tempa]
        mov     ebx,edx
        call    addlist
        jmp     .nn
         
.done:  mov     eax,[tempa]
        mov     ebx,0x0
        call    addlist
 
        mov     eax,[tempa]
        ret
 
;;; delete the next node from the list in ebx
delnode:
        cmp     word [ebx+node.next],0x0
        je      .done  ; no node to remove
        mov     eax,[ebx+node.next]
        freenode
        mov     eax,[eax+node.next]
        mov     [ebx+node.next],eax
.done:  ret
 
;;; insert a node with value ax after current node in ebx
insnode:
        mov     [tempb],ax
        mov     [tempc],ebx
        call    newnode
        mov     bx,[tempb]
        setnodev
        mov     ebx,[tempc]
        mov     ecx,[ebx+node.next]
        mov     [ebx+node.next],eax
        mov     [eax+node.next],ecx
        ret
         
;;; Print nospace message and exit with failure
nospace:
        push    dword nspmsg
        call    printf
        jmp     retfa           ; exit program with failure
 
;;; Print the list with head pointed to by ebx
printl:
        cmp     ebx,0x0
        je      .done           ; empty list passed
        mov     eax,0x0         ; zero register so that after next eax contains value
        mov     ax,[ebx+node.value]
        call    prteax
        mov     ebx,[ebx+node.next]
        jmp     printl
.done:  ret
         
;;; Print the value of eax.
prteax: push    eax
        push    dword msg
        call    printf
        pop     eax             ; remove arguments from stack
        pop     eax
        ret
 
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
         
section .data
 
nonodes equ     0x100           ; max number of nodes
onens   equ     0x8             ; space per node (_one_ _n_ode _s_pace)
maxnode equ     nodesp+((nonodes-1) * onens)+1
msg     db      `val: %x\n`, 0x0
nspmsg  db      `No space left for nodes\n`, 0x0
 
lista   dd      0x0             ; pointer to list a
listb   dd      0x0             ; pointer to list b
 
 
 
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
 
;;; According to the Linux Standard Base all memory reserverd is init to zero
section .bss
 
nodesp: resd    nonodes*3   ; reserve space for the nodes
 
tempa:  resd    1
tempb:  resd    1
tempc:  resd    1
tempn:  resd    1
list1:  resd    1
list2:  resd    1