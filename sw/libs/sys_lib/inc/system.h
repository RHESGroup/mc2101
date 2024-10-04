/**
 * @file  system.h
 * @version 1.0 
 * @date 9 Sep, 2022
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
 * @brief Memory map of the mc2021 microcontroller, definitions of the overall system 
 *
 */

#include <stdint.h>
 
#ifndef  _MC2101_H
#define  _MC2101_H

/**SOC clk frequency 50 MHz*/
#define SOC_CLK_FREQ 50000000

/**
 * @defgroup SOC memory map
 * @{
 */

/**peripherals base adress*/
#define SOC_PERIPHERALS_BASE_ADDR     ( 0x1A100000 )

/**GPIO peripheral base address*/
#define GPIO_BASE_ADDR                ( SOC_PERIPHERALS_BASE_ADDR + 0x0000 )

/**UART peripheral base address*/
#define UART_BASE_ADDR                ( SOC_PERIPHERALS_BASE_ADDR + 0x1000 )

/** @} */

/**
 * @defgroup General definitions
 *
 */
 
 /** 32 bit register pointer*/
 #define REGP32(x)                    ((volatile unsigned int *)(x))
 /** 32 bit register value*/
 #define REG32(x)                     (*((volatile unsigned int *)(x)))
 /** 16 bit register pointer*/
 #define REGP16(x)                    ((volatile uint16_t *)(x))
 /** 16 bit register value*/
 #define REG16(x)                     (*((volatile uint16_t *))(x))
 /** 8 bit register pointer*/
 #define REGP8(x)                     ((volatile uint8_t *)(x))
 /** 8 bit register value*/
 #define REG8(x)                      (*((volatile uint8_t *)(x)))
 
 /** @} */


#endif
