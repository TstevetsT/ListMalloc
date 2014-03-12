#include <stdio.h>
#include <stdlib.h>

int main() {
		int x;
	  int * value;

	  int first_list = listNew();

    x = size(first_list);
    printf("\nSize of list during listNew(): %d\n\n", x);
    	  
    while (x <= 4){
    	if (addHead (first_list, (x)) == NULL) return -1;
    		x++;
    	}
    x = size(first_list);
    printf("Size of list during addHead(): %d\n\n", x);

    removeHead(first_list, value);
    x = size(first_list);
    printf("Size of list during removeHead(): %d\n\n", x);
		printf("Removed value from head is: %d\n\n", value);
    
    while (x >= 0){
    	if (addTail (first_list, (x)) == NULL) return -1;
    		x--;
    	}
    	
    removeItem(first_list, 2, value);
    x = size(first_list);
    printf("Size of list during removeItem(): %d\n\n", x);
    printf("Removed value from index is: %d\n\n", value);
    
    itemAt(first_list, 5, value);
    
    removeTail(first_list, value);
    
    clear(first_list);
    
    /*;while (current != NULL) {
    ;    printf("%d\n", current->val);
    ;    current = current->next;
    ;}*/
    return 0;
}