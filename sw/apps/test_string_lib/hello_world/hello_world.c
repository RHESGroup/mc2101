/**
 * @file  hello_world.c
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
 * @brief Simple test on printf
 *
 */

#include "string_lib.h"
#include "uart.h"

void init_io(void)
{
    //init stdio to uart @9600 KHz
    uart_set_cfg(WORD_LENGTH_8,
                 STOP_BIT_LENGTH_1,
                 PARITY_OFF,
                 PARITY_ODD,
                 UART_DIV_BR_9600);
}

int main(void)
{
    init_io();
    printf("Hello World from MC2101!\n");
    return 0;
}















