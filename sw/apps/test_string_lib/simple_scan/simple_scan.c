/**
 * @file  simple_scan.c
 * @version 1.0 
 * @date 1 Sept, 2022
 * @copyright Copyright (C) 2022 CINI Cybersecurity National Laboratory and University of Teheran 
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
    //init stdio to uart @115200 KHz
    uart_set_cfg(3,0,0,0,867);
}

int main(void)
{
    init_io();
    char name[20];
    char surname[20];
    int age;
    printf("Insert name:\r\n");
    scanf("%s",name);
    printf("Insert surname:\r\n");
    scanf("%s",surname);
    printf("Insert age:\r\n");
    scanf("%d",&age);
    printf("You are %s %s and your age is %d\r\n",name,surname,age);
    return 0;
}
