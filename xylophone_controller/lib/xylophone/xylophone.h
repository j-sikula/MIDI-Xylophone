/**
 * @file xylophone.h
 * @defgroup xylophone Xylophone <xylophone.h>
 * @brief Header file for xylophone control using GPIO on AVR microcontrollers.
 *
 * This file defines constants, macros, and function prototypes for controlling
 * a xylophone with 8 notes using GPIO pins.
 */

#ifndef XYLOPHONE_H
#define XYLOPHONE_H

#include <avr/io.h> // AVR device-specific IO definitions

/// Pin definitions for xylophone notes
#define NOTE_C1 PD2 ///< GPIO pin for Note C1
#define NOTE_D1 PD3 ///< GPIO pin for Note D1
#define NOTE_E1 PD4 ///< GPIO pin for Note E1
#define NOTE_F1 PD5 ///< GPIO pin for Note F1
#define NOTE_G1 PD6 ///< GPIO pin for Note G1
#define NOTE_A1 PD7 ///< GPIO pin for Note A1
#define NOTE_H1 PB0 ///< GPIO pin for Note H1
#define NOTE_C2 PB1 ///< GPIO pin for Note C2

/// Timing and velocity constants
#define MAX_NOTE_ON 40   ///< Maximum duration of a note
#define MAX_VELOCITY 127 ///< Maximum note velocity

/**
 * @brief Initialize GPIO pins for the xylophone.
 */
void init_xylophone();

/**
 * @brief Play a specific note with the given velocity.
 *
 * @param note Note index (0-7).
 * @param velocity Note velocity (1-127).
 */
void play_note(uint8_t note, uint8_t velocity);

/**
 * @brief Set the GPIO pin for the given note to HIGH.
 *
 * @param note Note index (0-7).
 */
void write_high_note(uint8_t note);

/**
 * @brief Set the GPIO pin for the given note to LOW.
 *
 * @param note Note index (0-7).
 */
void write_low_note(uint8_t note);

/**
 * @brief Routine to handle note timing during playback.
 */
void timer_routine();

#endif // XYLOPHONE_H