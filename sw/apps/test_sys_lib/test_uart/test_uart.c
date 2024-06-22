/**
 * @file  test_uart.c
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
 * @brief Simple test on GPIO calls 
 *
 */

#include "system.h"
#include "uart.h"

//test set/get operations uart_set_int_en(uint8_t dr, uint8_t thre, uint8_t rls)

//isr rewritten just to clear any pending interrupt
void ISR_UART(void)
{
    uart_set_int_en(0,0,0);
    uart_get_isr();
}

int main(void)
{

    //test configuration @115200 baudrate, No Parity, 1 Stop, 5 char, Odd (100 MHz clk)
    uart_set_cfg(WORD_LENGTH_5, STOP_BIT_LENGTH_1, PARITY_OFF, PARITY_EVEN, UART_DIV_BR_115200, DEFAULT_PRESCALER);
    if(uart_get_cfg() != 0x10) return 1;

    //test configuration @9600 baudrate, Parity, 2 stop, 6 char, even
    uart_set_cfg(WORD_LENGTH_6, STOP_BIT_LENGTH_2, PARITY_ON, PARITY_EVEN, UART_DIV_BR_9600, DEFAULT_PRESCALER);
    if(uart_get_cfg() != 0x1D) return 1;

    //test configuration @57600 KHz, No Parity, 1 stop, 8 char, odd
    uart_set_cfg(WORD_LENGTH_8, STOP_BIT_LENGTH_1, PARITY_OFF, PARITY_ODD, UART_DIV_BR_57600, DEFAULT_PRESCALER);
    if(uart_get_cfg() != 0x03) return 1;

    //enable interrupt dr
    uart_set_int_en(1,0,0); //Data ready, THR empty, Receiver Line Status
    if(uart_get_int_en() != 0x1) return 1;

    // //disable interrupt dr, enable thre (should rise interrupt)
    // uart_set_int_en(0,1,0);
    // //if(uart_get_int_en() != 0x2) return 1;

    //disable thre, enable rls
    uart_set_int_en(0,0,1);
    if(uart_get_int_en() != 0x4) return 1;

    // //enable all interrupts
    // uart_set_int_en(1,1,1);
    // //if(uart_get_int_en() != 0x7) return 1;
    
    //disable all interrupts
    uart_set_int_en(0,0,0);
    if(uart_get_int_en() != 0x0) return 1;

    //set trigger level to 4 char
    uart_set_trigger_lv(1);
    //send char
    // uart_sendchar('A');
    // uart_sendchar('H');
    // uart_sendchar('E');
    // uart_sendchar('L');
    // uart_sendchar('L');
    // uart_sendchar('O');

    //check lsr says that thr is empty
    if(uart_get_lsr() != 0x60) return 1;
    //send string
    while (1)
    {
        uart_send("Hello World",13);
    }
    
    return 0;
}















