#include <stdio.h>
#include <unistd.h>

int main ()
{
        pid_t pid;

        pid = getpid();

        fprintf(stdout, "hello from pid:%d\n", (int)pid);

        return 0;
}
