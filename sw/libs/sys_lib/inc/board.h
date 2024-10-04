/**
 * @file  board.h
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
 * @brief reference pinout used for all board_test programs
 *
 */
 
 #ifndef _BOARD_H
 #define _BOARD_H
 
 /**
 * @defgroup BOARD GPIO PINS
 * @{
 */


 /** LEDs  */
 
 #define LEDR0      0
 #define LEDR1      1
 #define LEDR2      2
 #define LEDR3      3


  /** Switches */
 
 #define SW0        4
 #define SW1        5


  /** KEY BUTTONS */
 
 #define KEY1       6
 #define KEY2       7
 #define KEY3       8


 /** RGB LEDs  */

 #define LED4B      9
 #define LED4G      10
 #define LED4R      11
 #define LED5B      12
 #define LED5G      13
 #define LED5R      14
 
/** ChipKit Digital I/O Low */
#define  IO1        15
#define  IO2        16
#define  IO3        17
#define  IO4        18
#define  IO5        19
#define  IO6        20
#define  IO7        21
#define  IO8        22
#define  IO9        23
#define  IO10       24
#define  IO11       25
#define  IO12       26
#define  IO13       27
#define  IO14       28

/** ChipKit Digital I/O High */
#define  IO15       29
#define  IO16       30
#define  IO17       31





 /** @} */
 
 /**
 * @brief setup board GPIO and UART according to pin assignment
 * UART is set with the following configuration : 115200,NO-PARITY,1 STOP, 8 BIT
 */
 void board_setup();
 
 #endif
