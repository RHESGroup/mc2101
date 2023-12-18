-- **************************************************************************************
--	Filename:	uart_interrupt.vhd
--	Project:	CNL_RISC-V
--  Version:	1.0
--	History:
--	Date:		9 Sep 2022
--
-- Copyright (C) 2022 CINI Cybersecurity National Laboratory
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
-- from https://www.gnu.org/licenses/lgpl-3.0.txt3 
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
USE work.Constants.ALL;

--TODO: current version does not support DMA, MODEM, SCRATCHPAD, PRESCALER
--      all relative bits and registers are not implemented or hardwired   
--      check UART 16550 datasheet     


ENTITY uart_interrupt IS 
    GENERIC(
        FIFO_DEPTH : INTEGER;
        LOG_FIFO_D : INTEGER
    );
	PORT (
	    --system signals
		clk                 : IN  STD_LOGIC;
		rst                 : IN  STD_LOGIC;
		--INPUTS
		IER                 : IN  STD_LOGIC_VECTOR(7 DOWNTO 0); --Interrupt Enable Register: RLS, THRe, DR enables. Enables each of the possible interrupt sources
		rx_fifo_trigger_lv  : IN  STD_LOGIC_VECTOR(1 DOWNTO 0); --Receiver fifo trigger level
		rx_elements         : IN  STD_LOGIC_VECTOR(LOG_FIFO_D DOWNTO 0); --#elements in rx fifo
		tx_elements         : IN  STD_LOGIC_VECTOR(LOG_FIFO_D DOWNTO 0); --#elements in tx fifo
		rx_line_error       : IN  STD_LOGIC; --Parity error or Break error or Overrun error or frame error in rx line
		interrupt_clear     : IN  STD_LOGIC; --bit used to clear interrup line
		char_timeout        : IN  STD_LOGIC; --no data has been received and no data has been read from receiver fifo during a certain time
		--OUTPUTS
		interrupt           : OUT STD_LOGIC;
		interrupt_isr_code  : OUT STD_LOGIC_VECTOR(3 DOWNTO 0) --id of the interrupt raised
	);
END uart_interrupt;


ARCHITECTURE behavior OF uart_interrupt IS

    --Interrupt Enable Register used signals
    SIGNAL DR_int_enable: STD_LOGIC;
    SIGNAL TX_EMPTY_int_enable: STD_LOGIC;
    SIGNAL RX_LINE_int_enable: STD_LOGIC;
    
    --Receiver trigger level : An interrupt is generated when the number of words in the receiver's fifo is equal or greater than this trigger level 
    SIGNAL rx_trigger_reached: STD_LOGIC;
    
    --The uart interrupt controller is in charge of computing the last 4 bits of the Interrupt Status Register
    --ISRcode=ISR(3 DOWNTO 0)=InterruptIdentificationCode & Interrupt status
    --See the 'Interrupt sources and their identification codes in the ISR' table in the datasheet
    SIGNAL current_iic_register, next_iic_register: STD_LOGIC_VECTOR(3 DOWNTO 0);

BEGIN

    --Receiver data ready interrupt enable
    DR_int_enable<=IER(0); --Enables the data ready interrupt
    
    --Transmitter empty (data can be transmitted) interrupt enable
    TX_EMPTY_int_enable<=IER(1); --Enables the THR empty interrupt
    
    --Receiver line error interrupt enable
    RX_LINE_int_enable<=IER(2); --Enables the Receiver Line Status interrupt
    
    ---NOTE: The rest of the bits are not used because they are related to DMA. TODO
    
    --Receiver trigger level reached signal
    PROCESS(rx_elements, rx_fifo_trigger_lv)
    BEGIN
        rx_trigger_reached<='0';
        CASE rx_fifo_trigger_lv IS
            WHEN "00" => --("00"-->trigger level 1 [receiver fifo works as a single register])
                IF TO_INTEGER(UNSIGNED(rx_elements))=1 THEN
                    rx_trigger_reached<='1';
                END IF;
            WHEN "01" => --("01"-->trigger level 4 [receiver fifo reached 25%])
                IF TO_INTEGER(UNSIGNED(rx_elements))=4 THEN
                    rx_trigger_reached<='1';
                END IF;
            WHEN "10" => --("10"-->trigger level 8 [receiver fifo reached 50%])
                IF TO_INTEGER(UNSIGNED(rx_elements))=8 THEN
                    rx_trigger_reached<='1';
                END IF;
            WHEN OTHERS => --("11"-->trigger level 14[receiver fifo almost full])
                IF TO_INTEGER(UNSIGNED(rx_elements))=14 THEN
                    rx_trigger_reached<='1';
                END IF;
        END CASE;
    END PROCESS;
    
    --IICcode register update
    PROCESS(clk, rst)
    BEGIN
        IF rst='1' THEN
            current_iic_register<="0001"; --There is no interrupt pending
        ELSIF rising_edge(clk) THEN
            current_iic_register<=next_iic_register;
        END IF;
    END PROCESS;
    
    --IICcode computation
    --Priorities:
    --1)Receiver Line Status error
    --2)Receiver Data Ready OR Character timeout
    --3)Transmitter holding register is empty (data can be written)
    PROCESS(interrupt_clear, rx_line_error, RX_LINE_int_enable, DR_int_enable, rx_trigger_reached, TX_EMPTY_int_enable, tx_elements  )
    BEGIN --Change: ALL for sensitivity list is not compatible with all simulators. Explicit description of the list
        --interrupt reset
        IF interrupt_clear='0' THEN
            next_iic_register<=current_iic_register;
        ELSE
            next_iic_register<="0001";
        END IF;
        --Priority level 1
        IF (rx_line_error='1' AND RX_LINE_int_enable='1') THEN --If there ia an error in the Rx line and the interrupt is enabled(IER(2) = '1')...
            --receiver line status interrupt
            next_iic_register<="0110";
        --Priority level 2
        ELSIF (DR_int_enable='1' AND rx_trigger_reached='1') THEN --If the selected trigger level is reached and the interrupt is enabled(IER(0) = '1')...
            --receiver data ready interrupt
            next_iic_register<="0100";
        --Priority level 2
        ELSIF (DR_int_enable='1' AND char_timeout='1') THEN --If no data has been received from receiver's fifo during a certain time  and the interrupt is enabled(IER(0) = '1')...
            --receiver timeout interrupt
            next_iic_register<="1100";
        --Priority level 3
        ELSIF (TX_EMPTY_int_enable='1' AND TO_INTEGER(UNSIGNED(tx_elements))=0) THEN --If the number of elements in the FIFO is 0 and the interrupt is enabled(IER(1) = '1')...
            --transmitter empty interrupt
            next_iic_register<="0010";
        END IF;
    END PROCESS;

    interrupt_isr_code<=current_iic_register;
    --interrupt is asserted whenever the last bit in IICcode is cleared
    interrupt<=NOT(current_iic_register(0)); --This checks the value of the Interrupt status flag(ISR(0)). When there is no interruption, it is '1'


END behavior;
