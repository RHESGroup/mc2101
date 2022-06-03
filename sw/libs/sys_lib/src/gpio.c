/**
 * @file  gpio.c
 * @version 1.0 
 * @date 03 Jun, 2022
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
 * @brief GPIO library
 *
 */
 
 #include "gpio.h"
 
 void set_pin_direction(int pinnumber, int direction)
 {
    volatile int old_direction=REG32(PADDIR);
    if(direction == 0)
        old_direction &= ~(1<<pinnumber);
    else
        old_direction |= (1<<pinnumber);
    REG32(PADDIR)=old_direction;
 }
 
 int get_pin_direction(int pinnumber)
 {
    volatile int old_direction=REG32(PADDIR);
    old_direction &= (1<<pinnumber);
    return (old_direction>>pinnumber);
 }
 
 void set_pin_value(int pinnumber, int value)
 {
    volatile int old_output=REG32(PADOUT);
    if(value == 0)
        old_output &= ~(1<<pinnumber);
    else
        old_output |= (1<<pinnumber);
    REG32(PADOUT)=old_output;
 }
 
 int get_pin_value(int pinnumber)
 {
    volatile int input=REG32(PADIN);
    input = (input>>pinnumber);
    return (input & 0x01);
 }
 
 
 
 void set_pin_irq_enable(int pinnumber, int value)
 {
    volatile int old_irq=REG32(INTEN);
    if(value == 0)
        old_irq &= ~(1<<pinnumber);
    else
        old_irq |= (1<<pinnumber);
    REG32(INTEN)=old_irq;
 }
 
 int get_pin_irq_enable(int pinnumber)
 {
    volatile int old_irq=REG32(INTEN);
    old_irq &= (1<<pinnumber);
    return (old_irq>>pinnumber);
 }
 
 void set_pin_irq_type(int pinnumber, int value)
 {
    volatile int old_type0=REG32(INTTYPE0);
    volatile int old_type1=REG32(INTTYPE1);
    if ((value & 0x1))//inttype0(i)=1
        old_type0 |= (1<<pinnumber);
    else 
        old_type0 &= ~(1<<pinnumber);
        
    if((value & 0x2))//inttype1(i)=1
        old_type1 |= (1<<pinnumber);
    else
        old_type1 &= ~(1<<pinnumber);
    REG32(INTTYPE0) = old_type0;
    REG32(INTTYPE1) = old_type1;
 }
 
int get_pin_irq_type(int pinnumber)
{
    volatile int old_type0=REG32(INTTYPE0);
    volatile int old_type1=REG32(INTTYPE1);
    int type;
    old_type0 = (old_type0 >> pinnumber);
    old_type0 &= 0x01;
    old_type1 = (old_type1 >> pinnumber);
    old_type1 &= 0x01;
    type = old_type0;
    type |= (old_type1 << 1);
    return type;
}

int get_gpio_irq_status(void)
{
    return REG32(INTSTATUS);
}
 
 
 
 
 
 
 
 
 
 
