
.include "m16def.inc"

.def TMP1=R16
.def TMP2=R17
.def TMP3=R18
.def MESG_COUNT=R19
.def ZERO=R20
.def FULL=R21
.def CMD1=R22
.def CMD2=R23
.def STEPPER_MASK=R24

.MACRO STORE_REG
push TMP1
push TMP2
in TMP1, SREG
push TMP1
.ENDMACRO

.MACRO RESTORE_REG
pop TMP1
out SREG, TMP1
pop TMP2
pop TMP1
.ENDMACRO

.dseg
RAM_MESSAGES: .byte 60 ; reserve 60 bytes for maximum possible message size.

.eseg
.org 0x000
MESSAGES: 
	.db "Message1_testtest00",0x00,"Message2_isthisthingon?",0x00,"Message3_abcdefghi",0x00

.cseg
.org $000
rjmp START
.org URXCaddr
jmp URXC_ISR					; rx interrupt
.org UDREaddr
jmp UDRE_ISR					; UDR empty interrupt
.org UTXCaddr
jmp UTXC_ISR					; tx complete interrupt

.org $02A						; code space

UDRE_ISR:
	reti

UTXC_ISR:
	STORE_REG
	lpm TMP1, Z+
	cpi TMP1, 0x00
	breq MENU_FINISHED
	out UDR, TMP1
	out PORTA, TMP1
	RESTORE_REG
	reti
MENU_FINISHED:
	out PORTA, FULL
	sbi UCSRB, RXCIE ; reenable rx
	cbi UCSRB, TXCIE ; disable tx
	RESTORE_REG
	reti

URXC_ISR:
	STORE_REG
	clr TMP1
	in TMP1, UDR
	out PORTA, TMP1 ; debug

	cpi TMP1, '.'
	breq EXE_COMMAND

	cpi CMD1, 0xFF
	brne SET_CMD2
	mov CMD1, TMP1
	rjmp RX_END
SET_CMD2:
	mov CMD2, TMP1
RX_END:
	RESTORE_REG
	reti

EXE_TASK_1:
	call STEP_CLOCK
	jmp END_COMMAND

EXE_TASK_2:
	call STEP_ANTI
	jmp END_COMMAND

EXE_TASK_3:
	ldi TMP1, 100
C_180_LOOP:
	ldi TMP2, 10
C_DELAY_START:
	call Delay
	dec TMP2
	breq C_DELAY_DONE
	rjmp C_DELAY_START
C_DELAY_DONE:
	call STEP_CLOCK
	dec TMP1
	cpi TMP1, 0x00
	breq DONE_180
	rjmp C_180_LOOP

EXE_TASK_4:
	ldi TMP1, 100
A_180_LOOP:
	ldi TMP2, 10
A_DELAY_START:
	call Delay
	dec TMP2
	breq A_DELAY_DONE
	rjmp A_DELAY_START
A_DELAY_DONE:
	call STEP_ANTI
	dec TMP1
	cpi TMP1, 0x00
	breq DONE_180
	rjmp A_180_LOOP

DONE_180:
	out PORTA, ZERO
	call SEND_MENU
	rjmp END_COMMAND

EXE_COMMAND:
	cpi CMD2, 0xFF
	breq EXE_COMMAND_1
	cpi CMD2, '0'
	breq EXE_TASK_10
	cpi CMD2, '1'
	breq EXE_TASK_11
	rjmp END_COMMAND

EXE_COMMAND_1:
	cpi CMD1, '1'
	breq EXE_TASK_1
	cpi CMD1, '2'
	breq EXE_TASK_2
	cpi CMD1, '3'
	breq EXE_TASK_3
	cpi CMD1, '4'
	breq EXE_TASK_4
	cpi CMD1, '5'
	breq EXE_TASK_5
	cpi CMD1, '6'
	breq EXE_TASK_6
	cpi CMD1, '7'
	breq EXE_TASK_7
	cpi CMD1, '8'
	breq EXE_TASK_8
	cpi CMD1, '9'
	breq EXE_TASK_9

END_COMMAND:
	ser CMD1
	ser CMD2
	RESTORE_REG
	reti

EXE_TASK_5:
	cbi DDRD, 4
	cbi DDRD, 5
	cbi DDRD, 6
	cbi DDRD, 7
	rjmp END_COMMAND

EXE_TASK_6:
	call INIT_STEPPER
	rjmp END_COMMAND

EXE_TASK_7:
EXE_TASK_8:
EXE_TASK_9:
	call PRINT_THIRD_MESSAGE
	call SEND_MENU
	jmp END_COMMAND

EXE_TASK_10:
	ldi TMP1, 0x01
	call Write_instruc
	jmp END_COMMAND

EXE_TASK_11:
	ldi TMP1, 0x08
	out WDTCR, TMP1
	jmp END_COMMAND

START:
	ldi TMP1, LOW(RAMEND)
	out SPL, TMP1
	ldi TMP1, HIGH(RAMEND)
	out SPH, TMP1

	clr ZERO
	ser FULL

	out DDRA, FULL ; debug
	out PORTA, ZERO

	call INIT
	sei
	jmp MAIN_LOOP

INIT:
	ser CMD1								; empty commands
	ser CMD2

	rcall INIT_UART
	call INIT_LOOKUP_TABLE
	call MY_INIT_LCD
	; call Init_LCD
	; call PRINT_THIRD_MESSAGE
	call INIT_STEPPER
	call SEND_MENU

	ret

INIT_UART:
	;	set baud rate (9600,8,n,2)
 	ldi TMP1, 51
	ldi TMP2, 0x00
	out UBRRH, TMP2
	out	UBRRL, TMP1
	;	set rx and tx enable
	sbi UCSRB, RXEN
	sbi UCSRB, TXEN
	; enable uart interrupts
	sbi UCSRB, RXCIE
	sbi UCSRB, TXCIE
	ret

INIT_LOOKUP_TABLE:
	;	Set up address registers.
	ldi XL, 0x00
	ldi XH, 0x00
  ldi MESG_COUNT, 0x00

MY_INIT_LCD:
	call Init_LCD
	ldi TMP1, 0x01
	call Write_instruc
	ret

INIT_STEPPER:
	STORE_REG
	ldi STEPPER_MASK, 0x10
	in TMP1, DDRD 
	in TMP2, PORTD
	andi TMP1, DDRD
	andi TMP2, PORTD
	ori TMP1, 0xf0
	ori TMP2, 0x10
	out DDRD, TMP1
	out PORTD, TMP2
	RESTORE_REG
	ret

READ_MESSAGES:
	cpi MESG_COUNT, 3				; have we gotten 3 messages?
	breq FINISHED_LOOKUP
	
	ldi TMP1, 20
	mul TMP1, MESG_COUNT
	mov TMP1, R0
	out PORTA, TMP1					; calculate memory offset

	ldi YL, low(RAM_MESSAGES)
	ldi YH,	high(RAM_MESSAGES)
	add YL, TMP1
	brcc Y_NO_CARRY
	inc YH									; calculate correct memory address
Y_NO_CARRY:
	inc MESG_COUNT					; increment message count

	rcall READ_ONE_MESSAGE	; read another message from eep to ram.
	rjmp READ_MESSAGES

READ_ONE_MESSAGE:
	sbic EECR, EEWE	; wait to make sure there is no active write
	rjmp READ_ONE_MESSAGE
	out EEARH, XH
	out EEARL, XL
	sbi EECR, EERE
	in TMP2, EEDR
	st Y+, TMP2
	adiw XL, 1
	cpi TMP2, 0x00
	brne READ_ONE_MESSAGE
	ret

FINISHED_LOOKUP:
	ret

STEP_CLOCK:
	lsl STEPPER_MASK
	breq STEPPER_RESET_C
	rjmp STEPPER_OUT
STEPPER_RESET_C:
	ldi STEPPER_MASK, 0x10
	rjmp STEPPER_OUT

STEP_ANTI:
	lsr STEPPER_MASK
	cpi STEPPER_MASK, 0x08
	breq STEPPER_RESET_A
	rjmp STEPPER_OUT
STEPPER_RESET_A:
	ldi STEPPER_MASK, 0x80
	rjmp STEPPER_OUT

STEPPER_OUT:
	STORE_REG
	in TMP1, PORTD
	andi TMP1, 0x0f
	or TMP1, STEPPER_MASK
	out PORTD, STEPPER_MASK
	RESTORE_REG
	ret

SEND_MENU:
	STORE_REG
	ldi ZL, low(2*MENU)
	ldi ZH, high(2*MENU)

	lpm TMP1, Z+
	cbi UCSRB, RXCIE ; disable reception
	sbi UCSRB, TXCIE ; disable reception
	out PORTA, TMP1
	out UDR, TMP1 ; tx first char
	RESTORE_REG
	ret

PRINT_THIRD_MESSAGE:
	; STORE_REG
	ldi TMP1, 0x01
	call Write_instruc
	ldi YL, low(RAM_MESSAGES)
	ldi YH, high(RAM_MESSAGES)
	adiw YL, 40										; offset to third message
	clr TMP2

NEXT_CHAR:
	ld TMP1, Y+
	cpi TMP1, 0x00 								; is message done?
	breq END_PRINT_MESSAGE
	call Write_char
	inc TMP2											; increment counter
	cpi TMP2, 16									; have we finished the line space?
	breq NEXT_LINE
	rjmp NEXT_CHAR

NEXT_LINE:
	ldi TMP1, 0xC0								; move to next line
	call Write_instruc
	rjmp NEXT_CHAR								; continue printing chars

END_PRINT_MESSAGE:
	; RESTORE_REG
	ret

.include "LCD.s"

MAIN_LOOP:
	nop
	nop
	nop
	rjmp MAIN_LOOP

MENU:
	.db 0x1b, "[2J", 0x1b, "[H", "Project tasks:",0x0d,0x0a,"--------------",0x0d,0x0a,"1) Single step clockwise",0x0d,0x0a,"2) Single step anti-clockwise",0x0d,0x0a,"3) 180 deg. clockwise",0x0d,0x0a,"4) 180 deg. anti-clockwise",0x0d,0x0a, "5"
	.db ") Disable stepper",0x0d,0x0a,"6) Enable stepper",0x0d,0x0a,"7) Start ADC PWM Task",0x0d,0x0a,"8) Stop ADC PWM Task",0x0d,0x0a,"9) Print 3rd stored message to LCD",0x0d,0x0a,"10) Clear LCD",0x0d,0x0a,"11) Reset Microcontroller",0x0d,0x0a,0x00

.exit
