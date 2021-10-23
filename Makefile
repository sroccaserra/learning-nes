ASM_FILES = $(shell find src -type f -name '*.s')
OBJ_FILES = $(ASM_FILES:.s=.o)

NAME = program

build: $(NAME).nes $(NAME).dbg

src/main.o: src/main.s src/*.inc src/*.chr
	ca65 --debug-info src/main.s

%.o: %.s
	ca65 --debug-info $<

$(NAME).nes: $(OBJ_FILES)
	ld65 $(OBJ_FILES) -C nes.cfg -o $(NAME).nes --dbgfile $(NAME).nes.dbg

$(NAME).dbg: $(NAME).nes
	bash generate_bookmarks.sh $(NAME)

clean:
	rm -f **/*.o *.nes *.dbg
