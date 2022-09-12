/**
 * @file  test_gpio.c
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
#include "gpio.h"

int firstTestSet(void)
{
    set_pin_direction(0, GPIO_OUT);
    set_pin_direction(10, GPIO_OUT);
    set_pin_direction(20, GPIO_IN);
    set_pin_direction(30, GPIO_IN);
    if (get_pin_direction(0)!=GPIO_OUT)  return 1;
    if (get_pin_direction(10)!=GPIO_OUT) return 1;
    if (get_pin_direction(20)!=GPIO_IN)  return 1;
    if (get_pin_direction(20)!=GPIO_IN)  return 1;
    set_pin_value(0, GPIO_PIN_LOW);
    set_pin_value(10, GPIO_PIN_HIGH);
    if(get_pin_value(0)!=GPIO_PIN_LOW)   return 1;
    if(get_pin_value(10)!=GPIO_PIN_HIGH) return 1;
    set_pin_irq_type(20, GPIO_IRQ_RISE);
    set_pin_irq_type(30, GPIO_IRQ_FALL);
    if(get_pin_irq_type(20)!=GPIO_IRQ_RISE) return 1;
    if(get_pin_irq_type(30)!=GPIO_IRQ_FALL) return 1;
    set_pin_irq_enable(20, GPIO_INT_ENABLE);
    set_pin_irq_enable(30, GPIO_INT_ENABLE);
    if(get_pin_irq_enable(20)!=GPIO_INT_ENABLE) return 1;
    if(get_pin_irq_enable(30)!=GPIO_INT_ENABLE) return 1;
    return 0;
}

void error() { while(1); }; //if code goes here means that an error occured

int main(void)
{
    if(firstTestSet())
        error();
    //set GPIO(0)=HIGH
    set_pin_value(0, GPIO_PIN_HIGH);
    //set GPIO(0) inttype LEVEL0
    set_pin_irq_type(0, GPIO_IRQ_LVL0);
    //set GPIO(0) = 0; (this should NOT rise an interrupt beacuse GPIO(0) interrupt is not enabled)
    set_pin_value(0, GPIO_PIN_LOW);
    //enable GPIO(0) interrupt, now should rise interrupt
    set_pin_irq_enable(0, GPIO_INT_ENABLE);
    return 0;
}















