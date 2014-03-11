#include <stdio.h>
#include <stdlib.h>

int main() {

	  //node_t * test_list = listNew();
	  int * first_list = listNew();
	  int x = 1;
    //* test_list = listInit(*test_list);
    while (x <= 3){
    	if (addHead (first_list, ((x*5))) == NULL) return -1;
    		x++;
    	}
    /*test_list->val = 1;
    test_list->next = malloc(sizeof(node_t));
    test_list->next->val = 2;
    test_list->next->next = malloc(sizeof(node_t));
    test_list->next->next->val = 3;
    test_list->next->next->next = malloc(sizeof(node_t));
    ;test_list->next->next->next->val = 4;
    ;test_list->next->next->next->next = NULL;
    
    

    ;remove_by_value(&test_list, 3);

    ;print_list(test_list);
    
    ;while (current != NULL) {
    ;    printf("%d\n", current->val);
    ;    current = current->next;
    ;}*/
    return 0;
}