/*
; 14 March 2013
; Assignment 6 malloc3140.asm

; Compile with:
; nasm -f elf32 -g malloc3140.asm
; nasm -f elf32 -g list3140.asm
; gcc -o main test_malloc_list.c list3140.o malloc3140.o

; to run use ./main
*/

#include<stdio.h> 

struct rec
	{
    		int i;
    		float PI;
    		char A;
	};
	
	int main()
	{
		
//Malloc Implementation
	printf("**********************");
	printf("\nTesting Malloc Implementation");
	printf("\n**********************\n");
		
		/* testing of malloc goes here
		struct rec *ptr_one;
		ptr_one =(struct rec *) l_malloc (sizeof(struct rec));

		ptr_one->i = 10;		//(*ptr_one).i = 10;
    ptr_one->PI = 3.14;		//(*ptr_one).PI = 3.14;
    ptr_one->A = 'a';		//(*ptr_one).A = 'a';

    		printf("First value: %d\n", ptr_one->i);
    		printf("Second value: %f\n", ptr_one->PI);
    		printf("Third value: %c\n", ptr_one->A);

    		l_free(ptr_one);
    		
    		*/
    		
   	int a,n;
		int * ptr_data;

		printf ("Enter amount: ");
		scanf ("%d",&a);

		ptr_data = (int*) l_calloc ( a,sizeof(int) );
		if (ptr_data==NULL)
		{
			printf ("Error allocating requested memory");
			return -1;
		}

		for ( n=0; n<a; n++ )
		{
			printf ("Enter number #%d: ",n);
			scanf ("%d",&ptr_data[n]);
		}

		printf ("Output: ");
		for ( n=0; n<a; n++ )
			printf ("%d ",ptr_data[n]);

		int * buffer;
		/*get a initial memory block*/
		buffer = (int*) l_malloc (10*sizeof(int));
		if (buffer==NULL)
		{
			printf("Error allocating memory!");
			return -1;
		}

		/*get more memory with realloc*/
		buffer = (int*) l_realloc (ptr_data, 10*sizeof(int));
		if (buffer==NULL)
		{
			printf("Error reallocating memory!");
			//Free the initial memory block.
			l_free (buffer);
			return -1;
		}


	//List Implementation
	printf("\n\n**********************");
	printf("\nTesting List Implementation");
	printf("\n**********************\n");
	
		l_free (buffer);
		l_free (ptr_data);
		
			int x, y, value;

	  int first_list = listNew();

//print stuff
      y = 0;
      printf ("Size of listNew():    %d\n", (x = size(first_list)));  
      
      printf  ("Nodes in List at beginning:    \n");
      while (y < x){
    	itemAt(first_list, y, &value);
    	printf("%d;  ", value);
    	y++;}    
//done with print job
    
    while (x <= 2){
    	if (addHead (first_list, x) == NULL) return -1;
    		x++;
    	}
		addHead (first_list, 11111);
		
    x = 991;
    while (x <= 991){
    	if (addTail (first_list, x) == NULL) return -1;
    		x++;
    	}
    addTail (first_list, 99999);
        	
//print stuff
    	printf ("Size of List: %d\n", (x = size(first_list)));
      y = 0;
      printf  ("List after addHead and addTail:     ");
      while (y < x){
    	itemAt(first_list, y, &value);
    	printf("%d;  ", value); 
    	y++;}      printf  ("\n");
//done with print job

    removeItem(first_list, 2, &value);
    removeTail(first_list, &value);
    removeHead(first_list, &value);
    
//print stuff
    	printf ("Size of List: %d\n", (x = size(first_list)));
      y = 0;
      printf  ("List after removing item (2) tail, and head:    ");
      while (y < x){
    	itemAt(first_list, y, &value);
    	printf("%d;  ", value);
    	y++;}      printf  ("\n");
//done with print job
        
    clear(first_list);
    
//print stuff
    	printf ("Size of List after clear: %d\n", (x = size(first_list)));
      y = 0;
      printf  ("Nodes in List after clear():  ");
      while (y < x){
    	itemAt(first_list, y, &value);
    	printf("%d;  ", value); 
    	y++;}      printf  ("\n");
//done with print job

   	return 0;
	}