build: helloworld.nes

src/helloworld.o: src/helloworld.asm
	ca65 src/helloworld.asm

helloworld.nes: src/helloworld.o
	ld65 src/*.o -t nes -o helloworld.nes

clean:
	rm src/*.o *.nes

