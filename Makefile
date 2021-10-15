build: helloworld.nes

ASM_FILES = $(shell find src -type f -name '*.asm')
OBJ_FILES = $(ASM_FILES:.asm=.o)

%.o: %.asm
	ca65 $<

helloworld.nes: $(OBJ_FILES)
	ld65 $(OBJ_FILES) -t nes -o helloworld.nes

clean:
	rm -f **/*.o *.nes
