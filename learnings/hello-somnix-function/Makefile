.PHONY: build run clean

build:
	as --64 -o /tmp/hello-somnix-function.o main.s
	ld -m elf_x86_64 -e _start -o /tmp/hello-somnix-function /tmp/hello-somnix-function.o

run: build
	/tmp/hello-somnix-function

clean:
	rm -f /tmp/hello-somnix-function.o /tmp/hello-somnix-function
