/* Based on example code from https://cwe.mitre.org/data/definitions/77.html */

#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <sys/types.h>
#include <unistd.h>

#define CMD_MAX 256

int main(int argc, char** argv){

        uid_t uid, euid, uidnow;
    
        char cmd[CMD_MAX] = "/bin/cat ";
        
        /* get actual and effective uids */
        uid = getuid();
        euid = geteuid();

        printf("actual uid is: %d\n", uid);
        printf("effective uid is: %d\n", euid);

        if (euid == 0)
            printf("I am root!\n");
        else
            printf("I am normal!\n");
        
        /* execute some suspect code here to view the contents of file*/
        strcat(cmd, argv[1]);
        printf("showing contents of %s\n",argv[1]);
        system(cmd);
                
        /* change effective uid to actual and check */
        seteuid(uid);
        uidnow = geteuid();
        printf("euid now: %d\n", uidnow);

        printf("exit\n");
        
        return 0;
}
