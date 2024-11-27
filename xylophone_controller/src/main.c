/*
 * Use USART unit and transmit data between ATmega328P and computer.
 * (c) 2018-2024 Tomas Fryza, MIT license
 * (c) 2024 Mark Kovychev, Josef Sikula, MIT license
 *
 * Developed using PlatformIO and AVR 8-bit Toolchain 3.6.2.
 * Tested on Arduino Uno board and ATmega328P, 16 MHz.
 */

// -- Includes -------------------------------------------------------
#include <avr/io.h>        // AVR device-specific IO definitions
#include <avr/interrupt.h> // Interrupts standard C library for AVR-GCC
#include "timer.h"         // Timer library for AVR-GCC
#include <uart.h>          // Peter Fleury's UART library
#include <stdlib.h>        // C library. Needed for number conversions
#include "xylophone.h"
#include <stdio.h>

// -- Function definitions -------------------------------------------
/*
 * Function: Main function where the program execution begins
 * Purpose:  Use Timer/Counter1 and transmit UART data.
 * Returns:  none
 */
int main(void)
{
    uint16_t value;

    // Initialize USART to asynchronous, 8-N-1, 9600 Bd
    uart_init(UART_BAUD_SELECT(115200, F_CPU));

    TIM0_ovf_1ms();
    TIM0_ovf_enable();

    // Interrupts must be enabled, bacause of `uart_puts()`
    sei();

    init_xylophone();

    uint8_t volume;
    uint8_t is_reading_velocity = 0;

    // Infinite loop
    while (1)
    {
        // Get received data from UART
        value = uart_getc();
        
        if ((value & 0xff00) == 0) // If successfully received data from UART
        {

            if (!is_reading_velocity)
            {
                volume = (value & 0xff);
                is_reading_velocity = 1;
            }

            else
            {
                is_reading_velocity = 0;
                uint8_t note = (value & 0xff) - '0';
                play_note(note, volume);
            }
        }
    }

    // Will never reach this
    return 0;
}

// -- Interrupt service routines -------------------------------------
/*
 * Function: Timer/Counter1 overflow interrupt
 * Purpose:  Note pulse generation
 */
ISR(TIMER0_OVF_vect)
{
    timer_routine();
}
