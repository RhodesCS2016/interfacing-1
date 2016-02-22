
.include "m16def.inc"

.def TMP1=R16
.def TMP2=R17
.def TMP3=R18

.cseg
.org $000
rjmp START

.org $02A

START:	ldi TMP1, LOW(RAMEND)
	out SPL, TMP1
	ldi TMP1, HIGH(RAMEND)
	out SPH, TMP1

	sbi DDRB, 0

FLASH:	cbi PORTB, 0
	rcall DELAY
	sbi PORTB, 0
	rcall DELAY
	rjmp FLASH

DELAY:	ser TMP1
DEL1:	ser TMP2
DEL2:	ldi TMP3, 20
DEL3:	dec TMP3
	brne DEL3
	dec TMP2
	brne DEL2
	dec TMP1
	brne DEL1
	ret

.exit
