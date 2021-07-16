CC=gcc

all:
	$(CC) writedata.c -o writedata
	$(CC) readdata.c -o readdata

install:
	mv writedata /usr/bin
	mv readdata /usr/bin
	mkdir -p /usr/share/data/
	touch /usr/share/data/data.file
	chmod 666 /usr/share/data/data.file

clean:
	rm -rf writedata readdata

uninstall:
	rm -rf /usr/bin/writedata
	rm -rf /usr/bin/readdata
	rm -rf /usr/share/data/data.file
