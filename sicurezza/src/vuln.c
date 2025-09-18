#include <stdio.h>
#include <string.h>

void vuln_function(char *input){
	char buff[200];			// local variable (buffer)
	strcpy(buff, input);		// vulnerable function - copies into buffer without controls
}

int main(int argc, char *argv[]){
	if (argc != 2) return 1;	// check on args passed to the program
	vuln_function(argv[1]);		// call to vulnerable function	
	return 0;			// reaches only if no buffer overflow occured
}
