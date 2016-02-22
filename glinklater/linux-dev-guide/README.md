# Linux AVR Developer Guide

*Disclaimer*

This was done using Linux Mint based off of Ubuntu 14.04.1. Depending on your
distro results may vary.

## Serial Communication

Putty seems to be the easiest way to communicate with the board over serial.

**Installation**
```
  sudo apt-get install putty
```

**Connect to Dev Board**
```
  putty <your-port> -serial -sercfg 9600,n,8
```

My port for this was ```/dev/ttyACM0```

## Programming

**Installation**
```
  apt-get install avrdude avra
```

**Sanity Test**

If you do not get positive results from executing this then do not move onto programming.

```
  # Device Test
  avrdude -c stk500 -p atmega16 -P /dev/ttyACM0
```

**Programming**

Taken from: http://forum.arduino.cc/index.php/topic,37154.0.html

Executing this will wipe the current contents of the board and replace them with
ExampleX1.hexa

```
  # Programming
  avrdude -c stk500 -p atmega16 -P /dev/ttyACM0 -F -u -U flash:w:ExampleX1.hex
```

## Makefile

There is also a makefile included with various utilities available:

1. make -> build hex file
2. make upload -> build hex file (if necessary) and upload to Device
3. make serial -> open putty serial communication with Device.

Be sure to edit the makefile before use.
