#include<stdio.h>
#include<stdlib.h>

void * ptr[401];
int toop;
int i;
int s;
int u=0;
int range=2000;
int max=50;
	
	int main()
	{
		for (i =1; i<max; i++)
		{
			s = rand() % range+1;
			ptr[i] = l_malloc(s);
	    		printf("Pointer: %p Size: %i", ptr[i], s);
			if (i>1)
			{
				toop=ptr[i]-ptr[i-1];
				u=s+u;
				printf("   Byte Diff: %i TotalBytesUsed: %i\n", toop, u);
			}
			else printf("\n");
		}	
		
		int t;	
		for (i =0; i<(max/2); i++)
		{
			t = rand() % max+1;
		        l_free(ptr[t]);
			printf("%p has been freed\n", ptr[t]);
		}

		for (i =max+1; i<max*2; i++)
		{
			s = rand() % range+1;
			ptr[i] = l_malloc(s);
	    		printf("Pointer: %p Size: %i\n  ", ptr[i], s);
		}

		for (i =1; i<max*2; i++)
		{	
    			l_free(ptr[i]);
			//printf("%p have been freed\n",ptr[i]);
			ptr[i]=0;
		}
		asm("test:");
   		return 0;
	}
