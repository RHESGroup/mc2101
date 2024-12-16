/**
 * @file  uart.c
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
 * @brief UART library
 *
 */
 
 #include "uart.h"
 
 void uart_set_cfg (uint8_t word_length, 
                    uint8_t stop_bits, 
                    uint8_t parity_enable, 
                    uint8_t even_parity,  
                    uint16_t divisor,
                    uint8_t prescaler) //Now, the prescaler is also considered
 {
    if (divisor < 1) { //We must ensure that the divisor is at least 1
        REG8(DLL) = 0x01;
        REG8(DLM) = 0x00;
    } else {
        REG8(DLL) = (uint8_t)divisor;
        REG8(DLM) = (uint8_t)(divisor >> 8);
    }

    if (prescaler > 15) //We must ensure that the prescaler is maximun 15 because the register only uses 4 bits in reality
    {
        REG8(PRESCALER) = 0x0F;
    } else {
        REG8(PRESCALER) = prescaler;
    }
    
    REG8(LCR) = 0xff & (word_length | (stop_bits<<2) | (parity_enable<<3) | (even_parity<<4));
    REG8(IER) = 0x00;
 }

 
 uint8_t uart_get_cfg (void)
 {
    return REG8(LCR);
 }
 
 
 void uart_set_int_en(uint8_t dr, uint8_t thre, uint8_t rls)
 {
    REG8(IER) = 0xff & (dr | (thre<<1) | (rls<<2));
 }
 
 uint8_t uart_get_int_en (void)
 {
    return REG8(IER);
 }
 
 void uart_rx_rst (void)
 {
    REG8(FCR) |= 0x02;
    REG8(FCR) &= 0xfd;
 }
 
 void uart_tx_rst (void)
 {
    REG8(FCR) |= 0x04;
    REG8(FCR) &= 0xfb;
 }
 
 void uart_set_trigger_lv(uint8_t trig_lv)
 {
    REG8(FCR) = (0xff & (trig_lv << 6));
 }
 
 uint8_t uart_get_lsr (void)
 {
    return REG8(LSR);
 }
 
 uint8_t uart_get_isr (void)
 {
    return REG8(ISR);
 }
 
 
 char uart_getchar (void)
 {
    //wait until there is a char at receiver side
    while( (REG8(LSR) & 0x1) == 0); 
    return REG8(RHR);
 }

 void uart_sendchar (const char c)
 {
    //wait tx fifo to be empty so that char can be immediately send
    while( (REG8(LSR) & 0x60) == 0);
    REG8(THR) = c;
 }
 
 
 void uart_send (const char *str, unsigned int len)
 {
    unsigned int i;
    while(len > 0)
    {
  
        for(i=0; (i<UART_FIFO_DEPTH) && (len > 0); i++)
        {
            uart_sendchar(((uint8_t *)str)[i]);
            len--;
        }
        str += i;
    }
 }

 void uart_mode (uint8_t mode) 
 {
    REG8(MCR) = 0xff & (mode << 4);
 }
 uint8_t uart_get_mcr (void)
 {
    return REG8(MCR);
 }

 uint8_t uart_get_dll(void)
 {
    return REG8(DLL);
 }

 uint8_t uart_get_dlm(void)
 {
    return REG8(DLM);
 }

 uint8_t uart_get_prescaler(void)
 {
    return REG8(PRESCALER);
 }
 
 __attribute__ ((weak))
 void ISR_UART(void)
 {
    while(1);
 }
 
 