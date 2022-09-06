/**
 * @file  uart.h
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
 * @brief UART library
 *
 */
 
 #ifndef _UART_H
 #define _UART_H
 
 #include "system.h"
 
 /**
 * @defgroup UART registers map
 * @{
 */

/**IER ADDRESS*/
#define UART_IER              ( UART_BASE_ADDR + 0x0 )

/**ISR ADDRESS*/
#define UART_ISR              ( UART_BASE_ADDR + 0x1 )

/**FCR ADDRESS*/
#define UART_FCR              ( UART_BASE_ADDR + 0x2 )

/**LCR ADDRESS*/
#define UART_LCR              ( UART_BASE_ADDR + 0x3 )

/**LSR ADDRESS*/
#define UART_LSR              ( UART_BASE_ADDR + 0x4 )

/**DLL ADDRESS*/
#define UART_DLL              ( UART_BASE_ADDR + 0x5 )

/**DLM ADDRESS*/
#define UART_DLM              ( UART_BASE_ADDR + 0x6 )

/**RHR ADDRESS*/
#define UART_RHR              ( UART_BASE_ADDR + 0x7 )

/**THR ADDRESS*/
#define UART_THR              ( UART_BASE_ADDR + 0x7 )

/** @} */

/**
 * @defgroup UART registers pointers
 * @{
 */
 
 /**PADDIR*/
 #define  IER                 REGP8(UART_IER)
 
 /**PADIN*/
 #define  ISR                 REGP8(UART_ISR)
 
 /**PADOUT*/
 #define  FCR                 REGP8(UART_FCR)
 
 /**PADOUT*/
 #define  LCR                 REGP8(UART_LCR)
 
 /**INTEN*/
 #define  LSR                 REGP8(UART_LSR)
 
 /**INTTYPE0*/
 #define  DLL                 REGP8(UART_DLL)
 
 /**INTTYPE1*/
 #define  DLM                 REGP8(UART_DLM)
 
 /**INTSTATUS*/
 #define  RHR                 REGP8(UART_RHR)
 
 /**INTSTATUS*/
 #define  THR                 REGP8(UART_THR)
 
 /** @} */
 
 /**
 * @defgroup UART ISR codes
 * @{
 */
 
 /**ISR Code: Receiver Line Status*/
 #define ISR_RLS_CODE              0x6
 
 /**ISR Code: Received Data Ready*/
 #define ISR_RDR_CODE              0x4
 
 /**ISR Code: Reception Timeout*/
 #define ISR_RT_CODE               0xC
 
 /**ISR Code: Transmitter Holding Register Empty*/
 #define ISR_THRE_CODE             0x2
 
 /**FIFOs depth*/
 #define UART_FIFO_DEPTH           16
 
 /** @} */
 
 /**
 * @defgroup UART configuration defines
 * @{
 */
 
 #define WORD_LENGTH_5             0x0
 #define WORD_LENGTH_6             0x1
 #define WORD_LENGTH_7             0x2
 #define WORD_LENGTH_8             0x3
 #define STOP_BIT_LENGTH_1         0x0
 #define STOP_BIT_LENGTH_2         0x1
 #define PARITY_ON                 0x1
 #define PARITY_OFF                0x0
 #define PARITY_EVEN               0x1
 #define PARITY_ODD                0x0

 /** @} */
 
 /**
 * @defgroup UART divisor values for standard baudrates (50MHz clock reference)
 * @{
 */
 
 #define UART_DIV_BR_1200          41666
 #define UART_DIV_BR_9600          5207
 #define UART_DIV_BR_19200         2603
 #define UART_DIV_BR_57600         867
 #define UART_DIV_BR_115200        433
 
 /** @} */
 
 
 /**
 * @brief used for peripheral configuration, set LCR bits
 * @param word_length: word length (5, 6, 7, 8 char) 
 * @param stop_bits: number of stop bits (1 or 2)
 * @param parity_enable: parity enable
 * @param even_parity: even (1) odd (0)
 * @param divisor: 16 bit divisor value for baudrate
 * @warning interrupts are disabled
 */
 void uart_set_cfg (uint8_t word_length, 
                    uint8_t stop_bits, 
                    uint8_t parity_enable, 
                    uint8_t even_parity,  
                    uint16_t divisor);
 
 /**
 * @brief used to read the LCR register (used for uart configuration)
 * @return uart's current LCR value
 */
 uint8_t uart_get_cfg (void);
 
 /**
 * @brief used for peripheral interrupt configuration, set IER bits
 * @param dr: data ready interrupt enable
 * @param thre: transmitter empty interrupt enable
 * @param rls: receiver line status (rx line error notification) interrupt enable
 */
 void uart_set_int_en(uint8_t dr, uint8_t thre, uint8_t rls);
 
 /**
 * @brief used to read the IER register (Interrupt Enable Register)
 * @return uart's current IER value
 */
 uint8_t uart_get_int_en (void);
 
 /**
 * @brief reset rx fifo
 */
 void uart_rx_rst (void);
 
 /**
 * @brief reset tx fifo
 */
 void uart_tx_rst (void);
 
 /**
 * @brief set rx fifo trigger level, FCR register
 * @param trig_lv: 0 (1 char), 1 (4 char), 2 (8 char), 3 (14 char)
 */
 void uart_set_trigger_lv(uint8_t trig_lv);
 
 /**
 * @brief used to read the LSR register (Line Status Register)
 * @return uart's current LSR value
 */
 uint8_t uart_get_lsr (void);
 
 /**
 * @brief used to read the ISR register (Interrupt Status Register)
 * @return uart's current ISR value
 */
 uint8_t uart_get_isr (void);
 
 /**
 * @brief send char on tx line
 * @param c: character to be transmitted (ASCII)
 */
 void uart_sendchar (const char c);
 
 /**
 * @brief get char received
 * @return character received (ASCII)
 */
 char uart_getchar (void);
 
 /**
 * @brief send a string on uart tx line
 * @param str: text to be transmitted (ASCII)
 * @param len: text size
 */
 void uart_send (const char *str, unsigned int len);
 
 /**
 * @brief uart Interrupt handler (weak procedure)
 */
 void ISR_UART(void);
 
 #endif
 
 
 
 
 
