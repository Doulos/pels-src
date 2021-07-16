#include <stdio.h>
#include <stdlib.h>

int main() {
	char c[1000];
        FILE *fptr;
	
     	if ((fptr = fopen("/usr/share/data/data.file", "r")) == NULL) {
		printf("Error! File cannot be opened.");
		exit(1);
	}
	
	// reads text until newline is encountered
	fscanf(fptr, "%[^\n]", c);
	printf("Data from the file:\n%s\n", c);
	fclose(fptr);

	return 0;
}
