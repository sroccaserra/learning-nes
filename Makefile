build: helloworld.nes

helloworld.o: helloworld.asm
	ca65 helloworld.asm

helloworld.nes: helloworld.o
	ld65 helloworld.o -t nes -o helloworld.nes

clean:
	rm *.o *.nes

