all: test

test: test.o ray_tracing.o
	gcc $^ -o $@

ray_tracing.o: ray_tracing.asm
	nasm -f elf64 -F dwarf ray_tracing.asm

clean:
	rm -rf *.o *~ test
