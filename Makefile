#
# Ino Sketch Makefile
#
# Author: Stéphane Lavirotte
# Date: 2020/03/29

TARGET=blink.hex
TARGET_AXF=$(TARGET:.hex=.axf)
TARGET_ELF=$(TARGET:.hex=.elf)
TARGET_EEP=$(TARGET:.hex=.eep)

# Arduino stuff install dir
ARDUINO_DIR=/usr/share/arduino
# Simavr stuff install dir
SIMAVR_DIR=/home/user/EmuArdu/simavr/simavr

# Define compilers programs
CC=avr-gcc
CPP=avr-g++
AR=avr-ar
OBJ_COPY=avr-objcopy

# Configure MCU chracteristics
FREQ_CPU=16000000
MCU=atmega328p

# Configure thing for flashing target
MCU_AVRDUDE=m328p
TTY=/dev/ttyACM0
BAUDRATE=115200
PROGRAMMER=arduino

# Compile flags
GENERAL_FLAGS=-MMD -Wall -Os -mmcu=$(MCU) -DF_CPU=$(FREQ_CPU)L -fno-inline-small-functions -ffunction-sections -fdata-sections -DUSB_VID=null -DUSB_PID=null -DARDUINO=106
CFLAGS=$(GENERAL_FLAGS)
CPPFLAGS=$(GENERAL_FLAGS) -fno-exceptions

# Include files locations
INCLUDE_FILES=-I$(ARDUINO_DIR)/hardware/arduino/cores/arduino -I$(ARDUINO_DIR)/hardware/arduino/variants/standard -I$(SIMAVR_DIR)/sim/avr 

.PRECIOUS: %.elf

# Library sources
all: lib/libarduino.a $(TARGET) $(TARGET_EEP) $(TARGET_AXF)

flash: all
	avrdude -p $(MCU_AVRDUDE) -b $(BAUDRATE) -c $(PROGRAMMER) -P $(TTY) -v -U flash:w:$(TARGET)

simavr: all
	$(SIMAVR_DIR)/run_avr -m $(MCU) -f $(FREQ_CPU) $(TARGET_AXF)

lib/libarduino.a:
	@make -C lib

%.cpp: %.ino
	@echo "#include <Arduino.h>" > $@
	@echo  >> $@
	@cat $< >> $@

%.o: %.c
	$(CC) $(CFLAGS) $(INCLUDE_FILES) -o $@ -c $<

%.o: %.cpp
	$(CPP) $(CPPFLAGS) $(INCLUDE_FILES) -o $@ -c $<

%.axf: %.o simavr-addin.o
	$(CC) -Wall -gdwraf-2 -Wl,--relax,--gc-sections -Wl,--undefined=_mmcu,--section-start=.mmcu=0x910000 $(CFLAGS) -o $@ $^ lib/libarduino.a -lm

%.elf: %.o
	$(CC) -Wl,--gc-sections -mmcu=$(MCU) -o $@ $^ lib/libarduino.a -lm
	
%.eep: %.elf
	$(OBJ_COPY) -O ihex -j .eeprom --set-section-flags=.eeprom=alloc,load --no-change-warnings --change-section-lma .eeprom=0 $< $@
	
%.hex: %.elf
	$(OBJ_COPY) -O ihex -R .eeprom $< $@
	
.PHONY: clean

clean:
	@rm -f *.d *.o $(TARGET_ELF) $(TARGET_EEP) $(TARGET_AXF) $(TARGET)

mrproper: clean
	@rm -f *.vcd
	@make -C lib clean