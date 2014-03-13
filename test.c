#include<stdio.h>
#include<stdlib.h>

void * ptr[10];
int toop;
int i;
int s;
int u=0;
	
	int main()
	{
		for (i =0; i<10; i++)
		{
			s = i*87;
			ptr[i] = l_malloc(s);
	    		printf("Pointer: %p Size: %i\n", ptr[i], s);
			if (i>0)
			{
				toop=ptr[i]-ptr[i-1];
				u=s+u;
				printf("Diff: %i TotalUsed: %i\n", toop, u);
			}
		}		
		for (i =0; i<10; i++)
		{	
    			l_free(ptr[i]);
		}
   		return 0;
	}
