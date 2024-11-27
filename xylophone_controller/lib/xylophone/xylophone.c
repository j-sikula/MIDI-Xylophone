#include "xylophone.h"
#include "gpio.h"
#include "uart.h"
#include <stdlib.h> 

volatile uint8_t currentNote = 0;
volatile uint8_t is_note_playing = 0;
volatile uint16_t timer_cycle = 0;
volatile uint8_t correction[] = {0, 10, 0, 1, 5, 7, 8, 9};
void init_xylophone()
{
    GPIO_mode_output(&DDRD, NOTE_C1);
    GPIO_mode_output(&DDRD, NOTE_D1);
    GPIO_mode_output(&DDRD, NOTE_E1);
    GPIO_mode_output(&DDRD, NOTE_F1);
    GPIO_mode_output(&DDRD, NOTE_G1);
    GPIO_mode_output(&DDRD, NOTE_A1);
    GPIO_mode_output(&DDRB, NOTE_H1);
    GPIO_mode_output(&DDRB, NOTE_C2);

    GPIO_write_low(&PORTD, NOTE_C1);
    GPIO_write_low(&PORTD, NOTE_D1);
    GPIO_write_low(&PORTD, NOTE_E1);
    GPIO_write_low(&PORTD, NOTE_F1);
    GPIO_write_low(&PORTD, NOTE_G1);
    GPIO_write_low(&PORTD, NOTE_A1);
    GPIO_write_low(&PORTB, NOTE_H1);
    GPIO_write_low(&PORTB, NOTE_C2);
}

void play_note(uint8_t note, uint8_t velocity)
{
    if (note >= 0 && note < 8 && !is_note_playing)
    {
        write_high_note(note);
        currentNote = note;
        is_note_playing = 1;
        uint16_t temp= velocity * (MAX_VELOCITY - MIN_VELOCITY)/MAX_VELOCITY+ MIN_VELOCITY;
        timer_cycle = MAX_NOTE_ON *temp/ MAX_VELOCITY + correction[note];
            
        char uart_msg[4];
        itoa(timer_cycle, uart_msg, 10);
        uart_puts(uart_msg);
        uart_puts("\nTemp:\n");
        itoa(temp, uart_msg, 10);
        uart_puts(uart_msg);
    }
}

void write_high_note(uint8_t note)
{
    switch (note)
    {
    case 0:
        GPIO_write_high(&PORTD, NOTE_C1);
        break;

    case 1:
        GPIO_write_high(&PORTD, NOTE_D1);
        break;

    case 2:
        GPIO_write_high(&PORTD, NOTE_E1);
        break;

    case 3:
        GPIO_write_high(&PORTD, NOTE_F1);
        break;

    case 4:
        GPIO_write_high(&PORTD, NOTE_G1);
        break;

    case 5:
        GPIO_write_high(&PORTD, NOTE_A1);
        break;

    case 6:
        GPIO_write_high(&PORTB, NOTE_H1);
        break;

    case 7:
        GPIO_write_high(&PORTB, NOTE_C2);
        break;
    }
}

void write_low_note(uint8_t note)
{
    switch (note)
    {
    case 0:
        GPIO_write_low(&PORTD, NOTE_C1);
        break;

    case 1:
        GPIO_write_low(&PORTD, NOTE_D1);
        break;

    case 2:
        GPIO_write_low(&PORTD, NOTE_E1);
        break;

    case 3:
        GPIO_write_low(&PORTD, NOTE_F1);
        break;

    case 4:
        GPIO_write_low(&PORTD, NOTE_G1);
        break;

    case 5:
        GPIO_write_low(&PORTD, NOTE_A1);
        break;

    case 6:
        GPIO_write_low(&PORTB, NOTE_H1);
        break;

    case 7:
        GPIO_write_low(&PORTB, NOTE_C2);
        break;
    }
}

void timer_routine()
{
    if (timer_cycle != 0)
    {
        timer_cycle--;
    }
    else
    {
        write_low_note(currentNote);
        is_note_playing = 0;
    }
}
