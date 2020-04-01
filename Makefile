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
FREQ_MCU=16000000
MCU=atmega328p

# Configure thing for flashing target
MCU_AVRDUDE=m328p
TTY=/dev/ttyACM0
BAUDRATE=115200
PROGRAMMER=arduino

# Compile flags
GENERAL_FLAGS=-Os -w -Wall -mmcu=$(MCU) -DF_CPU=$(FREQ_MCU)L -ffunction-sections -fdata-sections -flto -MMD -DUSB_VID=null -DUSB_PID=null -DARDUINO=10812 -DARDUINO_AVR_UNO -DARDUINO_ARCH_AVR
CFLAGS=$(GENERAL_FLAGS) -std=gnu11 -fno-fat-lto-objects 
CPPFLAGS=$(GENERAL_FLAGS) -std=gnu++11 -x c++ -fpermissive -fno-exceptions -fno-threadsafe-statics 

# Include files locations
INCLUDES=-I$(ARDUINO_DIR)/hardware/arduino/cores/arduino 
INCLUDES+=-I$(ARDUINO_DIR)/hardware/arduino/variants/standard 
INCLUDES+=-I$(SIMAVR_DIR)/sim/avr 

.PRECIOUS: %.elf %.c

# Library sources
all: lib/libarduino.a $(TARGET) $(TARGET_EEP)
	@rm -f *.d

flash: all
	avrdude -p $(MCU_AVRDUDE) -b $(BAUDRATE) -c $(PROGRAMMER) -P $(TTY) -v -U flash:w:$(TARGET)

simavr: all $(TARGET_AXF)
	simavr -m $(MCU) -f $(FREQ_MCU) $(TARGET_AXF)

lib/libarduino.a:
	@mkdir -p lib/avr-libc
	@make -C lib

%.cpp: %.ino
	@echo "#include <Arduino.h>" > $@
	@echo >> $@
	@cat $< >> $@

%.c: %.gen
	@FREQ_MCU=$(FREQ_MCU) MCU="\"$(MCU)\"" VCD_OUTPUT_FILE="\"gtkwave_trace.vcd\"" ./gentoc.sh $< $@

%.o: %.c
	$(CC) $(CFLAGS) $(INCLUDES) -o $@ -c $<

%.o: %.cpp
	$(CPP) $(CPPFLAGS) $(INCLUDES) -o $@ -c $<

%.axf: %.o simavr-addin.o
	$(CC) -Wall -Wl,--relax,--gc-sections -Wl,--undefined=_mmcu,--section-start=.mmcu=0x910000 $(CFLAGS) -o $@ $^ lib/libarduino.a -lm

%.elf: %.o
	$(CC) -Wl,--gc-sections -mmcu=$(MCU) -o $@ $^ lib/libarduino.a -lm
	
%.eep: %.elf
	$(OBJ_COPY) -O ihex -j .eeprom --set-section-flags=.eeprom=alloc,load --no-change-warnings --change-section-lma .eeprom=0 $< $@
	
%.hex: %.elf
	$(OBJ_COPY) -O ihex -R .eeprom $< $@
	
.PHONY: clean

clean:
	@rm -f *.d *.o simavr-addin.c $(TARGET_ELF) $(TARGET_EEP) $(TARGET_AXF) $(TARGET)

mrproper: clean
	@rm -f *.vcd
	@make -C lib clean