#include <unistd.h>
#include <wait.h>
#include <stdio.h>
#include <seccomp.h>

int main(void) {
        int childPid;
        int status, rt;

        /* set up seccomp filtering */
        scmp_filter_ctx ctx = NULL;

        ctx = seccomp_init(SCMP_ACT_KILL);

/*      rt = seccomp_rule_add(ctx, SCMP_ACT_ALLOW, SCMP_SYS(clone), 0);
        if (rt < 0)
                goto error;
        rt = seccomp_rule_add(ctx, SCMP_ACT_ALLOW, SCMP_SYS(getpid), 0);
        if (rt < 0)
                goto error;
        rt = seccomp_rule_add(ctx, SCMP_ACT_ALLOW, SCMP_SYS(fstat), 0);
        if (rt < 0)
                goto error;
        rt = seccomp_rule_add(ctx, SCMP_ACT_ALLOW, SCMP_SYS(ioctl), 0);
        if (rt < 0)
                goto error;
        rt = seccomp_rule_add(ctx, SCMP_ACT_ALLOW, SCMP_SYS(execve), 0);
        if (rt < 0)
                goto error;
        rt = seccomp_rule_add(ctx, SCMP_ACT_ALLOW, SCMP_SYS(wait4), 0);
        if (rt < 0)
                goto error;
        rt = seccomp_rule_add(ctx, SCMP_ACT_ALLOW, SCMP_SYS(exit_group), 0);
        if (rt < 0)
                goto error;
        rt = seccomp_rule_add(ctx, SCMP_ACT_ALLOW, SCMP_SYS(write), 0);
        if (rt < 0)
                goto error;
        rt = seccomp_rule_add(ctx, SCMP_ACT_ALLOW, SCMP_SYS(brk), 0);
        if (rt < 0)
                goto error;
        rt = seccomp_rule_add(ctx, SCMP_ACT_ALLOW, SCMP_SYS(faccessat), 0);
        if (rt < 0)
                goto error;
        rt = seccomp_rule_add(ctx, SCMP_ACT_ALLOW, SCMP_SYS(openat), 0);
        if (rt < 0)
                       goto error;
        rt = seccomp_rule_add(ctx, SCMP_ACT_ALLOW, SCMP_SYS(mmap), 0);
        if (rt < 0)
                goto error;
        rt = seccomp_rule_add(ctx, SCMP_ACT_ALLOW, SCMP_SYS(close), 0);
        if (rt < 0)
                goto error;
        rt = seccomp_rule_add(ctx, SCMP_ACT_ALLOW, SCMP_SYS(read), 0);
        if (rt < 0)
                goto error;
        rt = seccomp_rule_add(ctx, SCMP_ACT_ALLOW, SCMP_SYS(mprotect), 0);
        if (rt < 0)
                goto error;
        rt = seccomp_rule_add(ctx, SCMP_ACT_ALLOW, SCMP_SYS(munmap), 0);
        if (rt < 0)
                goto error;
*/
        rt = seccomp_load(ctx);

        if (rt < 0)
                goto error;

        /* create child process */
        childPid = fork();

        if (childPid == 0) {
                execl("/home/root/hello", "/home/root/hello", ".", (char *) NULL);
        } else if (childPid > 0) {
                printf("PARENT<%d>: wait for child with pid=%d\n", getpid(),childPid);
                wait(&status);
                printf("PARENT<%d>: Child exit status %d \n", getpid(),WEXITSTATUS(status));
        } else if (childPid < 0) {
                perror("Failed to start new process\n");
        }

        goto noerror;

        error:
                seccomp_release(ctx);
                return -rt;

        noerror:
                return 0;
}
