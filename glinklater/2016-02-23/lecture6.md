# Lecture 6

## Timers

We have 8MHz clock, we can set so that our timer runs at 8KHz

* 8MHz -> 0.125 micro seconds
* 8KHz -> 128 micro seconds
  * Set timer divisor to 1024 (there is a register for this)

If we set Output Compare Register to 80 -> timer of 10ms

```avrasm
.org OC0addr
rjmp OC0_ISR

OC0_ISR:
    ; stop timer and reset to 0

    inc TIME              ; 10ms have passed
    ; if (TIME == 100)
    ; {
    ;   inc SECONDS;
    ;   TIME = 0;
    ; }
    cpi TIME, 100         ; Compare immediate
    beq <label>           ; Branch if TIME == 100
```

## RAM

We have three segments
* .eseg -> EEPROM
* .dseg -> RAM
* .cseg -> Flash Memory (Program Memory)

```avrasm
.dseg
Message:
    .byte 10              ; Reserve 10 bytes for "Message"
                          ; this is an assembler directive,
                          ; not part of assembly language.
Message2:
    .byte 5

.eseg
MY_MESSAGE:
    .db "Hello", 0x00     ; define byte -> insert value
                          ; any number of params

.cseg
    .org <somewhere that isn't being used>
    .db "My Message"
```

Note: ```rjmp``` has a limited range. Use jmp instead.

## Special RAM Access registers

```avrasm
; 2 registers represent a 16bit word for memory access.
R26 & R27 -> X
R28 & R29 -> Y
R30 & R31 -> Z
```

```MOV``` copy Rr -> Rd

```MOVW``` copy Rr & Rr + 1 -> Rd & Rd + 1

```LD``` load from X, Y or Z into Rd

```ST``` store to X, Y or Z.

```LDD``` is like an array access. for Y and Z only.

```LDS``` Load directly from SRAM, uses only a single 8bit register.

```SPM``` do not use this... it will kill the gnomes.

```LPM``` load from program memory.

## Button Bouncing

* Need to write a 1 to GIFR register

```
ldi TMP1, 0x01        ; or whatever the correct bit is.
out GIFR, TMP1        ; clear flags
```
