#include<stdio.h>
#include<stdlib.h>

	int main ()
	{
		int * buffer;

// i deleted a whole bunch of stuff here

		/*get more memory with realloc*/
		buffer = (int*) realloc (buffer, 20*sizeof(int));
		if (buffer==NULL)
		{
			printf("Error reallocating memory!");
			//Free the initial memory block.
			free (buffer);
			exit (1);
		}
		free (buffer);
		return 0;
	}