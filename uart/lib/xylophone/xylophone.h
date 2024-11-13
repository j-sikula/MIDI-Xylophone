#ifndef XYLOPHONE_H
#define XYLOPHONE_H

#include <avr/io.h>         // AVR device-specific IO definitions


#define NOTE_C1 PD2
#define NOTE_D1 PD3  
#define NOTE_E1 PD4
#define NOTE_F1 PD5
#define NOTE_G1 PD6
#define NOTE_A1 PD7
#define NOTE_H1 PB0
#define NOTE_C2 PB1

void init_xylophone();


void play_note(uint8_t note, uint8_t velocity);


#endif