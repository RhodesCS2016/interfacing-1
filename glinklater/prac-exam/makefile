PORT=/dev/ttyACM0
#PORT=/dev/ttyACM3
FILE=exam.s

all: makehex

makehex: $(FILE)
	avra -I /usr/lib/atmega16 $(FILE)

clean:
	rm -f *.elf *.hex *.o *.obj *.cof

upload: makehex
	avrdude -c stk500 -p atmega16 -P $(PORT) -F -u -U flash:w:$(FILE).hex -U eeprom:w:exam2016orig.eep.hex

upload-code: makehex
	avrdude -c stk500 -p atmega16 -P $(PORT) -F -u -U flash:w:$(FILE).hex

upload-eep: makehex
	avrdude -c stk500 -p atmega16 -P $(PORT) -F -u -U eeprom:w:$(FILE).eep.hex

orig:
	avrdude -c stk500 -p atmega16 -P $(PORT) -F -u -U flash:w:exam2016orig.hex -U eeprom:w:exam2016orig.eep.hex

orig-code:
	avrdude -c stk500 -p atmega16 -P $(PORT) -F -u -U flash:w:exam2016orig.hex

orig-eep:
	avrdude -c stk500 -p atmega16 -P $(PORT) -F -u -U eeprom:w:exam2016orig.eep.hex

serial:
	putty $(PORT) -serial -sercfg 9600,n,8
