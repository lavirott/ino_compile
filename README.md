# Ino compile

## Get this repository
`git clone https://github.com/lavirott/ino_compile.git`

## Installing dependencies
`sudo apt install gcc-avr avr-libc arduino simavr`

## Clone simavr to acces include files needed for simavr
`git clone https://github.com/buserror/simavr.git`

## Change variables in Makefile
Change the `SIMAVR_DIR` value in the first level Makefile to address the right directory.

Change the `TARGET` value in the first level Makefile to address the ino file you want to compile.

# Compile ino file
Compile arduino library and target source code and generate .hex file (and .elf and .eep)
* `make`

Compile simavr-addin, include it in firmware and launch simavr
* `make simavr`

Compile and Flash on a real hardware connected to TTY (/dev/ttyACM0 by default)
* `make flash`
