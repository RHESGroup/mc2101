/**
 * @file  board.c
 * @version 2.0 
 * @date 11 April, 2024
 * @copyright Copyright (C) 2024 CINI Cybersecurity National Laboratory
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
 * @brief init GPIO, UART peripherals
 *
 */
 
 #include "gpio.h"
 #include "uart.h"
 #include "board.h" 
 
 void board_setup()
 {
    /**Setup LEDR[i] as output pins*/
    for(int i=LEDR0; i<=LEDR3; i++)
        set_pin_direction(i,GPIO_OUT);
    
    /**Setup LED-RGB[i] as output pins*/
    for (int i = LED4B; i<=LED5R; i++)
        set_pin_direction(i,GPIO_OUT);
    

    /**Setup SW[i] as input pins*/
    for(int i=SW0; i<=SW1; i++)
        set_pin_direction(i,GPIO_IN);
        
    /**Setup KEY[i] as input pins*/
    for(int i=KEY1; i<=KEY3; i++)
        set_pin_direction(i,GPIO_IN);
        
    /**Setup uart for IO operations*/
    uart_set_cfg(WORD_LENGTH_8,
                 STOP_BIT_LENGTH_1,
                 PARITY_OFF,
                 PARITY_ODD,
                 UART_DIV_BR_115200,
                 DEFAULT_PRESCALER);
 }
