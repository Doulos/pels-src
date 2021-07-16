#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <sys/types.h>
#include <unistd.h>

#define CMD_MAX 256

int main(int argc, char** argv){

        uid_t uid, euid, uidnow;

        char cmd[CMD_MAX] = "/bin/cat ";

	/* Usage */
	if (argc < 2) {
		printf("Provide a filename or string\n");
		return 1;
	}

        /* get actual and effective uids and save for later */
        uid = getuid();
        euid = geteuid();

        printf("actual uid is: %d\n", uid);
        printf("effective uid is: %d\n", euid);

        if (euid == 0) { /* the executable belongs to root with SUID access mode*/
            printf("\nEffective EUID is root!\n");
            printf("Calling 'whoami' ... \n");
	    system("whoami");
            printf("Calling 'captest' with UID %d ... \n", uid);
	    system("captest");
	} else { /* executable has no privileges */ 
            printf("I have no privilege: e.g EUID != 0 \n"
		   "Try setting: \n"
		   "sudo chown root.root <this-executable> \n"
		   "sudo chmod u+s <this-executable> \n\n");
	}

        /* we become root here, by changing the real UID to be the EUID */
	printf("\nraise privileges by setting the real UID to 0. Check 'captest' ... \n");
        setuid(euid);
	system("captest"); /* as root, this will allow PRIVILEGE ESCALATION */

	/* execute some suspect code here to view the contents of file*/
        strcat(cmd, argv[1]);
        printf("\nshowing contents of %s\n",argv[1]);

	/* as per https://cwe.mitre.org/data/definitions/77.html */
       	system(cmd);

	printf("actual uid is: %d\n", uid);
        printf("effective uid is: %d\n\n", euid);

        /* become non-privileged again */
	printf("drop privileges by setting the real UID to non 0. Check 'captest' ... \n");
	setuid(uid);
        printf("real uid is now: %d\n\n", getuid());

	if (getuid == 0) /* this happens if the root user executed the program */
	{
		printf("failed to drop privileges: process still running as root. Exiting ...\n");
		return -1;
	}
        system("captest"); /* should NOT allow PRIVILEGE ESCALATION */

        /* now, change effective EUID to saved (non-privilege) real UID and check 
	 * that we can no longer raise and drop privileges.
	 * */
	printf("\ndrop privileges by setting the effective EUID to non 0 (one-way!). \n");
        seteuid(uid); /* one-way privilege drop */
        uidnow = geteuid();
        printf("effective EUID now: %d\n\n", geteuid());


	printf("try to change UID back to 0 ... \n");
	setuid(0);
        printf("real UID now: %d\n\n", getuid());

        printf("exit\n");

        return 0;
}
