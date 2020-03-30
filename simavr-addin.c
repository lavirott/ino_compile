#include <avr/io.h>

/*
 * This demonstrate how to use the avr_mcu_section.h file
 * The macro adds a section to the ELF file with useful
 * information for the simulator
 */
#include "avr_mcu_section.h"
AVR_MCU(16000000, "atmega328p");

/*
 * This small section tells simavr to generate a VCD trace dump with changes to these
 * registers.
 * Opening it with gtkwave will show you the data being pumped out into the data register
 * UDR0, and the UDRE0 bit being set, then cleared
 */

AVR_MCU_VCD_FILE("gtkwave_trace.vcd", 1000);

const struct avr_mmcu_vcd_trace_t _mytrace[]  _MMCU_ = {
	{ AVR_MCU_VCD_SYMBOL("DDRB"), .what = (void*)&DDRB, },	
	{ AVR_MCU_VCD_SYMBOL("PORTB"), .mask = (1 << PB6), .what = (void*)&PORTB, },	
};