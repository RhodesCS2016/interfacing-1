
.include "m16def.inc"

.def TMP1=R16
.def TMP2=R17
.def TMP3=R18
.def COUNT=R19

.cseg
.org $000
rjmp START
.org INT0addr
rjmp INT0_ISR					; Interrupt 0 routine
.org INT1addr
rjmp INT1_ISR					; Interrupt 1 routine

.org $02A						; code space

START:
	ldi TMP1, LOW(RAMEND)
	out SPL, TMP1
	ldi TMP1, HIGH(RAMEND)
	out SPH, TMP1

	rcall INIT
	sei
MAIN_LOOP:
	nop
	nop
	nop
	rjmp MAIN_LOOP

INIT:
	; setup port b as output for LEDs, port d as input for button
	; initial state to off for all and set counter to zero.
	clr TMP1
	out DDRD, TMP1				; ensure port d is an input
	sbi PORTD, 2				; pullups for int0
	sbi PORTD, 3				; pullups for int1
	clr TMP1
	out PORTB, TMP1				; port b all low, LEDs off
	ser TMP1
	out DDRB, TMP1
	clr COUNT
	ldi TMP1, 0x0e
	out MCUCR, TMP1
	ldi TMP1, 0xc0
	out GICR, TMP1
	ret

INT0_ISR:
	; increment counter
	push TMP1
	in TMP1, SREG
	push TMP1
	inc COUNT
	mov TMP1, COUNT
	out PORTB, TMP1

	rcall DELAY
	ldi TMP1, 0x40
	out GIFR, TMP1

	pop TMP1
	out SREG, TMP1
	pop TMP1
	reti

INT1_ISR:
	; decrement counter
	push TMP1
	in TMP1, SREG
	push TMP1
	dec COUNT
	mov TMP1, COUNT
	out PORTB, TMP1

	rcall DELAY
	ldi TMP1, 0x80
	out GIFR, TMP1

	pop TMP1
	out SREG, TMP1
	pop TMP1
	reti

DELAY:	ser TMP1
DEL1:	ser TMP2
DEL2:	ldi TMP3, 5
DEL3:	dec TMP3
	brne DEL3
	dec TMP2
	brne DEL2
	dec TMP1
	brne DEL1
	ret

; FLASH:	cbi PORTB, 0
; 	rcall DELAY
; 	sbi PORTB, 0
; 	rcall DELAY
; 	rjmp FLASH

.exit
