build: program.nes

ASM_FILES = $(shell find src -type f -name '*.asm')
OBJ_FILES = $(ASM_FILES:.asm=.o)

src/main.o: src/main.asm src/*.inc src/*.chr
	ca65 --debug-info src/main.asm

%.o: %.asm
	ca65 --debug-info $<

program.nes: $(OBJ_FILES)
	ld65 $(OBJ_FILES) -C nes.cfg -o program.nes --dbgfile program.nes.dbg

clean:
	rm -f **/*.o *.nes *.dbg
