#include <stdio.h>
#include <stdlib.h>

int main() {
		int x;
	  int value;

	  int first_list = listNew();

    x = size(first_list);
    printf("\nSize of list during listNew(): %d\n\n", x);
    	  
    while (x <= 4){
    	if (addHead (first_list, x) == NULL) return -1;
    		x++;
    	}
    x = size(first_list);
    printf("Size of list after addHead(): %d\n\n", x);
    
    while (x >= 0){
    	if (addTail (first_list, x) == NULL) return -1;
    		x--;
    	}
    x = size(first_list);
    printf("Size of list after addTail(): %d\n\n", x);
    	
    itemAt(first_list, 2, &value);
    printf("Removed value from itemAt(2git) is: %d\n\n", value);
    removeItem(first_list, 2, &value);
    printf("Removed value from index(2) is: %d\n\n", value);
    itemAt(first_list, 2, &value);
    printf("Removed value from itemAt(2) is: %d\n\n", value);
    
    removeTail(first_list, &value);
    printf("Removed value from removeTail() is: %d\n\n", value);
    
    removeHead(first_list, &value);
		printf("Removed value from removeHead() is: %d\n\n", value);
		
		itemAt(first_list, 5, &value);
    printf("Removed value from itemAt(5) is: %d\n\n", value);
        
    clear(first_list);
    
    /*;while (current != NULL) {
    ;    printf("%d\n", current->val);
    ;    current = current->next;
    ;}*/
    return 0;
}