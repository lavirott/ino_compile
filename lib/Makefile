#
# Arduino Library Makefile
#
# Author: Stéphane Lavirotte
# Date: 2020/03/29

TARGET=libarduino.a

# where you installed the Arduino app
ARDUINO_DIR=/usr/share/arduino

# Define compilers programs
CC=avr-gcc
CPP=avr-g++
AR=avr-ar
OBJ_COPY=avr-objcopy

# Configure MCU chracteristics
F_CPU=16000000
MCU=atmega328p

# Compile flags
GENERAL_FLAGS=-MMD -c -Os -Wall -ffunction-sections -fdata-sections -mmcu=$(MCU) -DF_CPU=$(F_CPU)L -DUSB_VID=null -DUSB_PID=null -DARDUINO=106
CFLAGS=$(GENERAL_FLAGS)
CPPFLAGS=$(GENERAL_FLAGS) -fno-exceptions

# Include files locations
INCLUDE_FILES=-I$(ARDUINO_DIR)/hardware/arduino/cores/arduino -I$(ARDUINO_DIR)/hardware/arduino/variants/standard

# Library sources
LIBRARY_DIR=$(ARDUINO_DIR)/hardware/arduino/cores/arduino

LIBRARY_SRCS_C=avr-libc/malloc.c avr-libc/realloc.c WInterrupts.c wiring.c wiring_analog.c wiring_digital.c \
			 wiring_pulse.c wiring_shift.c
LIBRARY_SRCS_CPP= CDC.cpp HardwareSerial.cpp HID.cpp IPAddress.cpp main.cpp new.cpp Print.cpp Stream.cpp \
				  Tone.cpp USBCore.cpp WMath.cpp WString.cpp
LIBRARY_OBJS=$(LIBRARY_SRCS_C:.c=.o) $(LIBRARY_SRCS_CPP:.cpp=.o)

vpath %.c $(LIBRARY_DIR)
vpath %.cpp $(LIBRARY_DIR)
vpath %.o .

all: $(TARGET)

$(TARGET): $(LIBRARY_OBJS)
	$(AR) rcs $@ $(LIBRARY_OBJS)

%.o: %.c
	$(CC) $(CFLAGS) $(INCLUDE_FILES) -o $@ $<

%.o: %.cpp
	$(CPP) $(CPPFLAGS) $(INCLUDE_FILES) -o $@ $<

.PHONY: clean

clean:
	rm -f *.d *.o avr-libc/*.d avr-libc/*o $(TARGET)
