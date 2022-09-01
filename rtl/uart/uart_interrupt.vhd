-- **************************************************************************************
--	Filename:	uart_interrupt.vhd
--	Project:	CNL_RISC-V
--  Version:	1.0
--	History:
--	Date:		19 Jul 2022
--
-- Copyright (C) 2022 CINI Cybersecurity National Laboratory and University of Teheran
--
-- This source file may be used and distributed without
-- restriction provided that this copyright statement is not
-- removed from the file and that any derivative work contains
-- the original copyright notice and the associated disclaimer.
--
-- This source file is free software; you can redistribute it
-- and/or modify it under the terms of the GNU Lesser General
-- Public License as published by the Free Software Foundation;
-- either version 3.0 of the License, or (at your option) any
-- later version.
--
-- This source is distributed in the hope that it will be
-- useful, but WITHOUT ANY WARRANTY; without even the implied
-- warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR
-- PURPOSE. See the GNU Lesser General Public License for more
-- details.
--
-- You should have received a copy of the GNU Lesser General
-- Public License along with this source; if not, download it
-- from https://www.gnu.org/licenses/lgpl-3.0.txt
--
-- **************************************************************************************
--
--	File content description:
--	uart interrupt controller
--
-- **************************************************************************************
LIBRARY IEEE;
LIBRARY STD;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.NUMERIC_STD.ALL;

--TODO: current version does not support DMA, MODEM, SCRATCHPAD, PRESCALER
--      all relative bits and registers are not implemented or hardwired   
--      check UART 16550 datasheet     


ENTITY uart_interrupt IS 
    GENERIC (
        FIFO_DEPTH   : INTEGER:=16;
        LOG_FIFO_D   : INTEGER:=4
    );
	PORT (
	    --system signals
		clk                 : IN  STD_LOGIC;
		rst                 : IN  STD_LOGIC;
		--input signals
		IER                 : IN  STD_LOGIC_VECTOR(2 DOWNTO 0); --Interrupt Enable Register: RLS, THRe, DR enables
		rx_fifo_trigger_lv  : IN  STD_LOGIC_VECTOR(1 DOWNTO 0); --Receiver fifo trigger level
		rx_elements         : IN  STD_LOGIC_VECTOR(LOG_FIFO_D DOWNTO 0); --#elements in rx fifo
		tx_elements         : IN  STD_LOGIC_VECTOR(LOG_FIFO_D DOWNTO 0); --#elements in tx fifo
		rx_line_error       : IN  STD_LOGIC; --Parity error or Break error or Overrun error or frame error in rx line
		interrupt_clear     : IN  STD_LOGIC; --bit used to clear interrup line
		char_timeout        : IN  STD_LOGIC; --no data has been received and no data has been read from receiver fifo during a certain time
		--output signals signals
		interrupt           : OUT STD_LOGIC;
		interrupt_isr_code  : OUT STD_LOGIC_VECTOR(3 DOWNTO 0) --id of the interrupt raised
	);
END uart_interrupt;


ARCHITECTURE behavior OF uart_interrupt IS

    --Interrupt Enable Register used signals
    SIGNAL DR_int_enable: STD_LOGIC;
    SIGNAL TX_EMPTY_int_enable: STD_LOGIC;
    SIGNAL RX_LINE_int_enable: STD_LOGIC;
    
    --Receiver trigger level 
    --("00"-->trigger level 1 [receiver fifo works as a single register])
    --("01"-->trigger level 4 [receiver fifo reached 25%])
    --("10"-->trigger level 8 [receiver fifo reached 50%])
    --("11"-->trigger level 14[receiver fifo almost full])
    SIGNAL rx_trigger_reached: STD_LOGIC;
    
    --The uart interrupt controller is in charge of computin the last 4 bits of the Interrupt Status Register
    --ISRcode=ISR(3 DOWNTO 0)=InterruptIdentificationCode & Interrupt status
    --See the 'Interrupt sources and their identification codes in the ISR' table in the datasheet
    SIGNAL current_iic_register, next_iic_register: STD_LOGIC_VECTOR(3 DOWNTO 0);

BEGIN

    --Receiver data ready interrupt enable
    DR_int_enable<=IER(0);
    
    --Transmitter empty (data can be transmitted) interrupt enable
    TX_EMPTY_int_enable<=IER(1);
    
    --Receiver line error interrupt enable
    RX_LINE_int_enable<=IER(2);
    
    --Receiver trigger level reached signal
    PROCESS(rx_elements, rx_fifo_trigger_lv)
    BEGIN
        rx_trigger_reached<='0';
        CASE rx_fifo_trigger_lv IS
            WHEN "00" =>
                IF TO_INTEGER(UNSIGNED(rx_elements))=1 THEN
                    rx_trigger_reached<='1';
                END IF;
            WHEN "01" =>
                IF TO_INTEGER(UNSIGNED(rx_elements))=4 THEN
                    rx_trigger_reached<='1';
                END IF;
            WHEN "10" =>
                IF TO_INTEGER(UNSIGNED(rx_elements))=8 THEN
                    rx_trigger_reached<='1';
                END IF;
            WHEN OTHERS =>
                IF TO_INTEGER(UNSIGNED(rx_elements))=14 THEN
                    rx_trigger_reached<='1';
                END IF;
        END CASE;
    END PROCESS;
    
    --IICcode register update
    PROCESS(clk, rst)
    BEGIN
        IF rst='1' THEN
            current_iic_register<="0001";
        ELSIF rising_edge(clk) THEN
            current_iic_register<=next_iic_register;
        END IF;
    END PROCESS;
    
    --IICcode computation
    --Priorities:
    --1)Receiver Line Status error
    --2)Receiver Data Ready OR Character timeout
    --3)Transmitter holding register is empty (data can be written)
    PROCESS(ALL)
    BEGIN
        --interrupt reset
        IF interrupt_clear='0' THEN
            next_iic_register<=current_iic_register;
        ELSE
            next_iic_register<="0001";
        END IF;
        
        IF (rx_line_error='1' AND RX_LINE_int_enable='1') THEN
            --receiver line status interrupt
            next_iic_register<="0110";
        ELSIF (DR_int_enable='1' AND rx_trigger_reached='1') THEN
            --receiver data ready interrupt
            next_iic_register<="0100";
        ELSIF (DR_int_enable='1' AND char_timeout='1') THEN
            --receiver timeout interrupt
            next_iic_register<="1100";
        ELSIF (TX_EMPTY_int_enable='1' AND TO_INTEGER(UNSIGNED(tx_elements))=0) THEN
            --transmitter empty interrupt
            next_iic_register<="0010";
        END IF;
    END PROCESS;

    interrupt_isr_code<=current_iic_register;
    --interrupt is asserted whenever the last bit in IICcode is cleared
    interrupt<=NOT(current_iic_register(0));


END behavior;
