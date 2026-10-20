.PHONY: build run clean

build:
	as --64 -o /tmp/hello-somnix-function-inputs.o main.s
	ld -m elf_x86_64 -e _start -o /tmp/hello-somnix-function-inputs /tmp/hello-somnix-function-inputs.o

run: build
	/tmp/hello-somnix-function-inputs

clean:
	rm -f /tmp/hello-somnix-function-inputs.o /tmp/hello-somnix-function-inputs
