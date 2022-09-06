/**
 * @file  board.h
 * @version 1.0 
 * @date 6 Sep, 2022
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
 * @brief reference pinout used for all board_test programs
 *
 */
 
 #ifndef _BOARD_H
 #define _BOARD_H
 
 /**
 * @defgroup BOARD GPIO PINS
 * @{
 */
 
 /** Switches */
 
 #define SW0        0
 #define SW1        1
 #define SW2        2
 #define SW3        3
 #define SW4        4
 #define SW5        5
 #define SW6        6
 #define SW7        7
 #define SW8        8
 #define SW9        9
 
 /** LEDs  */
 
 #define LEDR0      10
 #define LEDR1      11
 #define LEDR2      12
 #define LEDR3      13
 #define LEDR4      14
 #define LEDR5      15
 #define LEDR6      16
 #define LEDR7      17
 #define LEDR8      18
 #define LEDR9      19
 
 /** KEY BUTTONS */
 
 #define KEY1       20
 #define KEY2       21
 #define KEY3       22
 
 /** @} */
 
 /**
 * @brief setup board GPIO and UART according to pin assignment
 * UART is set with the following configuration : 115200,NO-PARITY,1 STOP, 8 BIT
 */
 void board_setup();
 
 #endif
