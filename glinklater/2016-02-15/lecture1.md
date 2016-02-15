# Lecture 1

## Architecture

8 bit architecture

Code space and RAM are completely different. Code is stored in flash memory not RAM

We work with General Purpose Working Registers (GPWR -> R0 to R31) and IO registers where we load instructions and parameters.

We have 1KB of RAM

We also have EEPROM (512B non-volatile memory) -> we won't be using this because it has a RW cycle of about 100000 writes. You can kill the chip in under a second with this.

Program Memory (8k words) stores program code.

## IO Registers

* ADC
* Timers/Counters
* UART/Serial
