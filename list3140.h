
#ifndef __LIST_3140_H
#define __LIST_3140_H

//A structure to manage a list of integers, its internal structure
//is opaque to user of the list functions below. In other words
//the layout of this structure is up to you.
struct _List3140;

//A global const that holds the size of a 
//struct _List3140 (ie sizeof(struct _List3140))
extern const unsigned int List3140Size;

//Allocate AND Initialize a new list
//returns a pointer to the newly allocated list or NULL on error
struct _List3140 *listNew();

//Initialize the list structure pointed to by list
//returns 0 on failure, 1 on success
int listInit(struct _List3140 *list);

//Add val at the head of list
//returns 0 on failure, 1 on success
int addHead(struct _List3140 *list, int val);

//Remove the integer at the head of the list returning
//the value of that integer in *val (if val is not NULL)
//returns 0 on failure, 1 on success
int removeHead(struct _List3140 *list, int *val);

//Add val at the tail of list
//returns 0 on failure, 1 on success
int addTail(struct _List3140 *list, int val);

//Remove the integer at the tail of the list returning
//the value of that integer in *val (if val is not NULL)
//returns 0 on failure, 1 on success
int removeTail(struct _List3140 *list, int *val);

//Retrieve the integer at index n of the list returning
//the value of that integer in *val (if val is not NULL)
//returns 0 on failure, 1 on success
int itemAt(struct _List3140 *list, unsigned int n, int *val);

//Remove the integer at index n of the list returning
//the value of that integer in *val (if val is not NULL)
//returns 0 on failure, 1 on success
int removeItem(struct _List3140 *list, unsigned int n, int *val);

//return the size of list
unsigned int size(struct _List3140 *list);

//clear all data from list. The size of list will be zero
//following this operation
void clear(struct _List3140 *list);

#endif

