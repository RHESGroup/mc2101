/**
 * @file  board_test_interrupts.c
 * @version 1.0 
 * @date 12 Sep, 2022
 * @copyright Copyright (C) 2022 CINI Cybersecurity National Laboratory
 * This source file may be used and distributed without
 * restriction provided that this copyright statement is not
 * removed from the file and that any derivative work contains
 * the original copyright notice and the associated disclaimer.
 * This source file is free software; you can redistribute it
 * and/or modify it under the terms of the GNU Lesser General
 * Public License as published by the Free Software Foundation;
 * either version 3.0 of the License, or (at your option) any
 * later version.
 * This source is distributed in the hope that it will be
 * useful, but WITHOUT ANY WARRANTY; without even the implied
 * warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR
 * PURPOSE. See the GNU Lesser General Public License for more
 * details.
 * You should have received a copy of the GNU Lesser General
 * Public License along with this source; if not, download it
 * from https://www.gnu.org/licenses/lgpl-3.0.txt
 * @brief Board test for button and switch interrupts
 *
 */

#include "string_lib.h"
#include "uart.h"
#include "gpio.h"
#include "board.h"

void waste_time()
{
    for(int i=0; i<200000; i++)
        asm volatile("nop");
}

//gpio isr
void ISR_GPIO(void)
{
    //switches are not debounced!
    //this is just a test program, switches should not trigger interrupts on edges
    //better to use them on logic level
    waste_time();
    
    switch(get_gpio_irq_status())
    {
        case 1<<SW0:
            printf("SW0 switched!\r\n");
            set_pin_value(LEDR0,!get_pin_value(LEDR0));
            break;
            
        case 1<<SW1:
            printf("SW1 switched!\r\n");
            set_pin_value(LEDR1,!get_pin_value(LEDR1));
            break;
        default: printf("Unknown GPIO\r\n"); break;        
    } 
}

int main(void)
{  
    board_setup();
    
    printf("Please switch some switches SW[0-1]\r\n");
    
    //enable interrupt for all switches as rising edges
    for(int i=SW0; i<=SW1; i++)
    {
        set_pin_irq_type(i,GPIO_IRQ_RISE);
        set_pin_irq_enable(i,GPIO_INT_ENABLE);
    }
    
    //switch on all leds
    for(int i=LEDR0; i<=LEDR3; i++)
        set_pin_value(i,GPIO_PIN_HIGH);

    //wait for switches to be switched
    while(1);;
    
    return 0;
}
