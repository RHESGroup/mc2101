/**
 * @file  gpio.h
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
 * @brief GPIO library
 *
 */
 
 #ifndef _GPIO_H
 #define _GPIO_H
 
 #include "system.h"
 
 /**
 * @defgroup GPIO registers map
 * @{
 */

/**PADDIR ADDRESS*/
#define GPIO_PADDIR                ( GPIO_BASE_ADDR + 0x00 )
/**PADIN ADDRESS*/
#define GPIO_PADIN                 ( GPIO_BASE_ADDR + 0x04 )
/**PADOUT ADDRESS*/
#define GPIO_PADOUT                ( GPIO_BASE_ADDR + 0x08 )
/**INTEN ADDRESS*/
#define GPIO_INTEN                 ( GPIO_BASE_ADDR + 0x0C )
/**INTTYPE0 ADDRESS*/
#define GPIO_INTTYPE0              ( GPIO_BASE_ADDR + 0x10 )
/**INTTYPE1 ADDRESS*/
#define GPIO_INTTYPE1              ( GPIO_BASE_ADDR + 0x14 )
/**INTSTATUS ADDRESS*/
#define GPIO_INTSTATUS             ( GPIO_BASE_ADDR + 0x18 )

/** @} */

 /**
 * @defgroup GPIO registers pointers
 * @{
 */
 
 /**PADDIR*/
 #define  PADDIR                   REGP32(GPIO_PADDIR)
 /**PADIN*/
 #define  PADIN                    REGP32(GPIO_PADIN)
 /**PADOUT*/
 #define  PADOUT                   REGP32(GPIO_PADOUT)
 /**INTEN*/
 #define  INTEN                    REGP32(GPIO_INTEN)
 /**INTTYPE0*/
 #define  INTTYPE0                 REGP32(GPIO_INTTYPE0)
 /**INTTYPE1*/
 #define  INTTYPE1                 REGP32(GPIO_INTTYPE1)
 /**INTSTATUS*/
 #define  INTSTATUS                REGP32(GPIO_INTSTATUS)
 
 /** @} */
 
 /**
 * @defgroup GPIO general definitions
 * @{
 */
 
 /**Pad Input  direction value*/
 #define GPIO_IN                   0x0
 /**Pad Output direction value */
 #define GPIO_OUT                  0x1
 /**Voltage LOW*/
 #define GPIO_PIN_LOW              0x0
 /**Voltage HIGH*/
 #define GPIO_PIN_HIGH             0x1
 /**Enable interrupt*/
 #define GPIO_INT_ENABLE           0x1
 /**Disable interrupt*/
 #define GPIO_INT_DISABLE          0x0
 /**Interrupt Logic Level 1 sensitivity*/
 #define GPIO_IRQ_LVL1             0x0
 /**Interrupt Logic Level 0 sensitivity*/
 #define GPIO_IRQ_LVL0             0x1
 /**Interrupt Rising edge sensitivity*/
 #define GPIO_IRQ_RISE             0x2
 /**Interrupt Falling edge sensitivity*/
 #define GPIO_IRQ_FALL             0x3
 
 /** @} */
 
/**
 * @brief used to set a pin direction to IN/OUT
 * @param pinnumber: pin id (0 to 31)
 * @param direction: input=GPIO_IN, output=GPIO_OUT
 */
void set_pin_direction(int pinnumber, int direction);

/**
 * @brief used to get a pin direction
 * @param pinnumber: pin id (0 to 31)
 * @return pin's current direction
 */
int get_pin_direction(int pinnumber);

/**
 * @brief used to set a pin voltage to HIGH/LOW
 * @param pinnumber: pin id (0 to 31)
 * @param value: 0=GPIO_PIN_LOW, 1=GPIO_PIN_HIGH
 */
void set_pin_value(int pinnumber, int value);
  
/**
 * @brief used to get a pin voltage
 * @param pinnumber: pin id (0 to 31)
 * @return pin's current voltage level
 */
int get_pin_value(int pinnumber);

/**
 * @brief used to enable or disable interrupt from a pin
 * @param pinnumber: pin id (0 to 31)
 * @param enable: GPIO_INT_ENABLE to enable pin's interrupt, GPIO_INT_DISABLE to disable it.
 */
void set_pin_irq_enable(int pinnumber, int value);

/**
 * @brief used to check if a pin interrupt is enabled
 * @param pinnumber: pin id (0 to 31)
 * @return pin's interrupt enable flag
 */
int get_pin_irq_enable(int pinnumber);

/**
 * @brief used to configure the behavior of pin's interrupt
 * Pins can rise interrupts (if enabled) on RISE/FALL Edges or just on LOGIC LEVELS
 * @param pinnumber: pin id (0 to 31)
 * @param type: LOGIC0=GPIO_IRQ_LVL0, LOGIC1=GPIO_IRQ_LVL1, RISE=GPIO_IRQ_RISE, FALL=GPIO_IRQ_FALL 
 */
void set_pin_irq_type(int pinnumber, int value);

/**
 * @brief used to configure get the behavior of pin's interrupt
 * @param pinnumber: pin id (0 to 31)
 * @return pin's interrupt type
 */
int get_pin_irq_type(int pinnumber);

/**
 * @brief used to read the gpio INTSTATUS register
 * @return gpio's current interrupt status register value
 * @warning this function is responsible also to deassert the gpio interrupt line
 */
int get_gpio_irq_status(void);

/**
 * @brief gpio Interrupt handler (weak procedure)
 */
 void ISR_GPIO(void);

 #endif
