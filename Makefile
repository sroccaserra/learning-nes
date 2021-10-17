build: helloworld.nes

ASM_FILES = $(shell find src -type f -name '*.asm')
OBJ_FILES = $(ASM_FILES:.asm=.o)

%.o: %.asm
	ca65 --debug-info $<

helloworld.nes: $(OBJ_FILES)
	ld65 $(OBJ_FILES) -C nes.cfg -o helloworld.nes --dbgfile helloworld.nes.dbg

clean:
	rm -f **/*.o *.nes
