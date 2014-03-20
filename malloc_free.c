#include<stdio.h>

struct rec
	{
    		int i;
    		float PI;
    		char A;
	};
	
	int main()
	{
		struct rec *ptr_one;
		ptr_one =(struct rec *) l_malloc (sizeof(struct rec));

		ptr_one->i = 10;		//(*ptr_one).i = 10;
    ptr_one->PI = 3.14;		//(*ptr_one).PI = 3.14;
    ptr_one->A = 'a';		//(*ptr_one).A = 'a';

    		printf("First value: %d\n", ptr_one->i);
    		printf("Second value: %f\n", ptr_one->PI);
    		printf("Third value: %c\n", ptr_one->A);

    		l_free(ptr_one);
    		
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
		buffer = (int*) l_realloc (ptr_data, 10);
		if (buffer==NULL)
		{
			printf("Error reallocating memory!");
			//Free the initial memory block.
			l_free (buffer);
			return -1;
		}

		l_free (buffer);
		l_free (ptr_data);

   	return 0;
	}