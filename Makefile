build: program.nes

ASM_FILES = $(shell find src -type f -name '*.s')
OBJ_FILES = $(ASM_FILES:.s=.o)

src/main.o: src/main.s src/*.inc src/*.chr
	ca65 --debug-info src/main.s

%.o: %.s
	ca65 --debug-info $<

program.nes: $(OBJ_FILES)
	ld65 $(OBJ_FILES) -C nes.cfg -o program.nes --dbgfile program.nes.dbg

clean:
	rm -f **/*.o *.nes *.dbg
