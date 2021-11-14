ASM_FILES = $(shell find src -type f -name '*.s')
OBJ_FILES = $(ASM_FILES:.s=.o)

NAME = program

ROM = $(NAME).nes
SYMBOLS = $(NAME).nes.dbg
FCEUX_BOOKMARKS = $(NAME).dbg
FCEUX_DEBUG_MARKERS = $(NAME).nes.0.nl

build: $(ROM) $(FCEUX_BOOKMARKS) $(FCEUX_DEBUG_MARKERS)

src/main.o: src/main.s src/*.inc src/*.chr
	ca65 --debug-info src/main.s

%.o: %.s
	ca65 --debug-info $<

$(ROM): $(OBJ_FILES)
	ld65 $(OBJ_FILES) -C nes.cfg -o $(ROM) --dbgfile $(SYMBOLS)

$(FCEUX_BOOKMARKS): $(ROM)
	bash generate_bookmarks.sh $(SYMBOLS) > $(FCEUX_BOOKMARKS)

$(FCEUX_DEBUG_MARKERS): $(ROM)
	bash generate_debug_markers.sh $(SYMBOLS) > $(FCEUX_DEBUG_MARKERS)

watch:
	fswatch -o -e '.*' -i '\.s$$' -i '\.inc$$' -i '\.chr$$' src | while read ; do make ; echo '----' ; done

clean:
	rm -f **/*.o *.nes *.dbg *.nl
