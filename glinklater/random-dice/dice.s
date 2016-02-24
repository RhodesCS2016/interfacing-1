
.include "m16def.inc"

.def TMP1=R16
.def TMP2=R17
.def TMP3=R18
.def TIME=R19
.def COUNT=R20
.def DIV=R21
.def ZERO=R24
.def FULL=R25

.cseg
.org $000
jmp START
.org INT0addr
rjmp INT0_ISR					; Interrupt 0 routine
.org INT1addr
rjmp INT1_ISR					; Interrupt 1 routine
.org OVF1addr
rjmp TIMER1_OVF_ISR

.org $02A						; code space

TIMER1_OVF_ISR:
	out TCCR1B, ZERO
	out PORTB, ZERO
	reti

INT0_ISR:
	push TMP1
	in TMP1, SREG
	push TMP1

	; zero timer
	out TCNT1H, ZERO
	out TCNT1L, ZERO
	out PORTB, ZERO
	
	; disable int0 and enable int1
	ldi TMP1, 0x80
	out GICR, TMP1
	sbi PORTB, 0

	rcall DELAY
	ldi TMP1, 0x40
	out GIFR, TMP1

	; turn LED on
	sbi PORTB, 1
	cbi PORTB, 0
	; start timer
	ldi TMP1, 0x05
	out TCCR1B, TMP1	

	pop TMP1
	out SREG, TMP1
	pop TMP1
	reti

INT1_ISR:
	push TMP1
	in TMP1, SREG
	push TMP1
	
	; stop timer
	out TCCR1B, ZERO
	; disable int1 and enable int0
	ldi TMP1, 0x40
	out GICR, TMP1
	; read timer bytes and display
	in TMP2, TCNT1L
	in TMP1, TCNT1H

MOD:
	cp TMP1, DIV
	brlo MOD_EXIT
	sub TMP1, DIV
	rjmp MOD

MOD_EXIT:
	out PORTB, TMP1

	pop TMP1
	out SREG, TMP1
	pop TMP1
	reti
	; END INT1_ISR

DELAY:	ser TMP1
DEL1:	ser TMP2
DEL2:	ldi TMP3, 0x60
DEL3:	dec TMP3
	brne DEL3
	dec TMP2
	brne DEL2
	dec TMP1
	brne DEL1
	ret

START:
	ldi TMP1, LOW(RAMEND)
	out SPL, TMP1
	ldi TMP1, HIGH(RAMEND)
	out SPH, TMP1

	ser FULL
	ldi ZERO, 0x00
	ldi DIV, 10

	rcall INITIALIZE_PORTS
	rcall INITIALIZE_TIMER
	rcall INITIALIZE_INTERRUPTS
	sei
	
MAIN_LOOP:
	nop
	nop
	nop
	rjmp MAIN_LOOP

INITIALIZE_PORTS:
	; port b output for LEDs
	out PORTB, ZERO
	out DDRB, FULL
	; port d input for interrupts
	out DDRD, ZERO

	; enable pullups
	sbi PORTD, 2
	sbi PORTD, 3
	ret

INITIALIZE_TIMER:
	; enable timer1 interrupt
	ldi TMP1, 0x04
	out TIMSK, TMP1
	; zero timer
	out TCNT1H, ZERO
	out TCNT1L, ZERO
	ret

INITIALIZE_INTERRUPTS:
	; enable interrupts
	ldi TMP1, 0x40
	out GICR, TMP1
	ldi TMP1, 0x0a
	out MCUCR, TMP1
	ret

.exit
