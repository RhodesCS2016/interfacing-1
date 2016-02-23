# Lecture 3

All Ports have 3 registers that govern their behaviour.

## Interrupts

When executing INT0_ISR we need to preserve registers, most importantly the SREG

SREG is an IO Register, needs to be read into GPWR using ```IN```
