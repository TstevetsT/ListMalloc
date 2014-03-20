#include<stdio.h>
#include<stdlib.h>

	int main ()
	{
		int * buffer;

		/*get a initial memory block*/
		buffer = (int*) malloc (10*sizeof(int));

		/*free initial memory block*/
		free (buffer);
		return 0;
	}