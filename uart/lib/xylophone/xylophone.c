#include "xylophone.h"
#include "gpio.h"
#include "gpio.c"

void init_xylophone()
{
 GPIO_mode_output(&DDRD, NOTE_C1);
 GPIO_mode_output(&DDRD, NOTE_D1);
 GPIO_mode_output(&DDRD, NOTE_E1);
 GPIO_mode_output(&DDRD, NOTE_F1);
 GPIO_mode_output(&DDRD, NOTE_G1);
 GPIO_mode_output(&DDRD, NOTE_A1);
 GPIO_mode_output(&DDRD, NOTE_H1);
 GPIO_mode_output(&DDRD, NOTE_C2);

}

void play_note(uint8_t note, uint8_t velocity)
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
       GPIO_write_high(&PORTD, NOTE_H1);
        break;

    case 7:
       GPIO_write_high(&PORTD, NOTE_C2);
        break;   
    }
    
}