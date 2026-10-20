.PHONY: build run clean

build:
	as --64 -o /tmp/hello-somnix.o main.s
	ld -m elf_x86_64 -e _start -o /tmp/hello-somnix /tmp/hello-somnix.o

run: build
	/tmp/hello-somnix

clean:
	rm -f /tmp/hello-somnix.o /tmp/hello-somnix
