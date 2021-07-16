# name of object file
obj-m := badmod.o

# cross compilation env vars
ARCH := arm64
CROSS_COMPILE := aarch64-poky-linux-

# Set KDIR to kernel source dir
KDIR := /var/lib/homes/simon/tmp/khc/kernel/
PWD := $(shell pwd)

all:
	make  ARCH=$(ARCH) CROSS_COMPILE=$(CROSS_COMPILE) \
				-C $(KDIR) M=$(PWD) modules
