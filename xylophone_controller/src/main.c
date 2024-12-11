/**
 * @mainpage MIDI Xylophone Controller
 *
 * @section intro_sec Introduction
 *
 * This project is a MIDI Xylophone Controller that uses an ATmega328P microcontroller
 * to receive simplified MIDI commands via UART and play corresponding notes on a xylophone.
 *
 * @section dependencies_sec Dependencies
 *
 * - ATmega328P microcontroller
 * - PlatformIO
 * - Peter Fleury's UART library
 * - Timer library
 * - GPIO library
 *
 * @section author_sec Authors
 * - Mark Kovychev (2024)
 * - Ilia Zhigachev (2024)
 * - Josef Sikula (2024)
 * - Peter Fleury (2015)
 * - Tomas Fryza (2018-2024)
 * 
 *
 * @section license_sec License
 *
 * MIT License, see the LICENSE file;
 * (c) 2015 Peter Fleury, GNU General Public License Version 3; 
 * (c) 2019-2024 Tomas Fryza, MIT license
 */

/**
 @file main.c
 @defgroup main Main program

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

// -- Function definitions -------------------------------------------
/**
 * Function: Main function where the program execution begins
 * Purpose:  Sets Timer/Counter1, receives and transmits UART data.
 * Returns:  none (forever loop)
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

    // Infinite loop
    while (1)
    {
        // Get received data from UART
        value = uart_getc();
        if ((value & 0xff00) == 0) // If successfully received data from UART
        {
            uint8_t note = (value & 0xff) - '0';
            play_note(note, 127);
            uart_putc(note + '0');
        }
    }

    // Will never reach this
    return 0;
}

// -- Interrupt service routines -------------------------------------
/**
 * Function: Timer/Counter1 overflow interrupt
 * Purpose:  Note pulse generation
 */
ISR(TIMER0_OVF_vect)
{
    // used for debugging
    static uint8_t index = 0;
    if (index >= 255)
    {
        //uart_putc('0'); // Send '0' to UART every 255 ms
        index = 0;
    }
    else
    {
        index++;
    }
    
    // Call the timer routine
    timer_routine();
}
