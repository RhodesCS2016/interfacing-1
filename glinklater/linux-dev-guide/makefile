PORT=/dev/ttyACM0
FILE=helloWorld.s

all: makehex

makehex: $(FILE)
	avra -I /usr/lib/atmega16 $(FILE)

clean:
	rm -f *.elf *.hex *.o *.obj *.cof

upload: makehex
	avrdude -c stk500 -p atmega16 -P $(PORT) -F -u -U flash:w:$(FILE).hex

serial:
	putty $(PORT) -serial -sercfg 9600,n,8
