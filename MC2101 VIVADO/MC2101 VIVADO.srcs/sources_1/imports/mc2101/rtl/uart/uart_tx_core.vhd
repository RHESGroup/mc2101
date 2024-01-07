-- **************************************************************************************
--	Filename:	uart_tx_core.vhd
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
-- from https://www.gnu.org/licenses/lgpl-3.0.txt
--
-- **************************************************************************************
--
--	File content description:
--	uart transmitter control and shift register
--
-- **************************************************************************************

LIBRARY IEEE;
LIBRARY STD;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.NUMERIC_STD.ALL;

ENTITY uart_tx_core IS 
	PORT (
	    --system signals
		clk             : IN  STD_LOGIC;
		rst             : IN  STD_LOGIC;
		--input signals
		divisor         : IN  STD_LOGIC_VECTOR(15 DOWNTO 0);--divisor value for baudrate
		parity_bit_en   : IN  STD_LOGIC;  --enable for parity bit
		parity_type     : IN  STD_LOGIC;  --even(0) or odd parity check 
		data_width      : IN  STD_LOGIC_VECTOR(1 DOWNTO 0); --data bits in the frame can be on 5,6,7,8 bits
		stop_bits       : IN  STD_LOGIC;  --number of stop bits (0 == 1 stop bit) (1 == 2 stop bits)
		tx_data_i       : IN  STD_LOGIC_VECTOR(7 DOWNTO 0); --data to be transmitted
		tx_valid        : IN  STD_LOGIC; --some data is ready to be transmitted
		--output signals signals
		tx_ready        : OUT STD_LOGIC; --transmitter ready for next data
		tx_out          : OUT STD_LOGIC --TX line
	);
END uart_tx_core;

--How to guarantee a transition in each frame?
--UART line keeps at logic 1 when IDLE
--Stop bits are always at logic 1
--Start bit is always at logic 0
--A new frame causes the start bit to make a transition from 1 to 0. The start bit transition synchronizes clocks at the beginning of the frame.
--Receiver checks the start bit and changes its clock. 

--Order of UART message:
--Start bit(logic 0) -> Message(LSB first) -> Parity bit -> Stop bits(logic 1)


ARCHITECTURE behavior OF uart_tx_core IS

    --transmitter FSM states
    TYPE statetype IS (S_IDLE, S_START_BIT, S_DATA_BITS, S_PARITY_BIT, S_STOP_BIT1, S_STOP_BIT2);
    SIGNAL current_state, next_state: statetype;
    
    --parity value computed
    SIGNAL parity_value: STD_LOGIC;
    
    --frame data bit counter
    SIGNAL current_data_bit, next_data_bit: UNSIGNED(2 DOWNTO 0);
    
    --register used to save the data to be transmitted
    SIGNAL reg_tx_data: STD_LOGIC_VECTOR(7 DOWNTO 0);
     
    
    --number of data bits to be transmitted
    SIGNAL target_data_bits: UNSIGNED(2 DOWNTO 0);
    
    --signal used to enable baudrate generator
    SIGNAL baudgen: STD_LOGIC;
    
    --counter for baudrate
    SIGNAL count : UNSIGNED(15 DOWNTO 0);
    
    --signal used to indicate the end of a bit frame
    SIGNAL bit_done: STD_LOGIC;
    
    --signal used to sample data to be transmitted 'tx_data_i' at before S_START
    SIGNAL sample_data_in: STD_LOGIC; 
    
BEGIN

    --parity value computation 
    parity_value <= reg_tx_data(7) XOR 
                    reg_tx_data(6) XOR 
                    reg_tx_data(5) XOR 
                    reg_tx_data(4) XOR 
                    reg_tx_data(3) XOR 
                    reg_tx_data(2) XOR 
                    reg_tx_data(1) XOR 
                    reg_tx_data(0) XOR (parity_type); --CHANGE: Now, EVEN(1) and ODD(0) to follow the protocol 
                    
    --This signal makes reference to the expected word length
    target_data_bits <= "100" WHEN data_width="00" ELSE
                        "101" WHEN data_width="01" ELSE
                        "110" WHEN data_width="10" ELSE
                        "111";

    --updata reg_tx_data
    PROCESS(clk, rst)
    BEGIN
        IF rst='1' THEN
            reg_tx_data<=(OTHERS=>'0');
        ELSIF rising_edge(clk) THEN
            IF (sample_data_in='1' AND current_state=S_IDLE) THEN
                reg_tx_data<=tx_data_i;
            ELSIF sample_data_in='1' THEN
                reg_tx_data<='0' & reg_tx_data(7 DOWNTO 1);
            END IF;
        END IF;        
    END PROCESS;
    
    --baudrate generator
    PROCESS(clk, rst)
    BEGIN
        IF (rst='1' OR baudgen='0') THEN
            count<=(OTHERS=>'0');
            --bit_done<='0';
        ELSIF rising_edge(clk) THEN
            IF count=UNSIGNED(divisor) THEN
                count<=(OTHERS=>'0');
                --bit_done<='1';
            ELSE
                count<=count + 1;
               -- bit_done<='0';
            END IF;
        END IF;
    END PROCESS;
    
    bit_done <= '1' WHEN baudgen = '1' ELSE '0'; --Change: change to avoid being two clock cycles in the START BIT state
    
    --FSM registers update
    PROCESS(clk, rst)
    BEGIN
        IF rst='1' THEN
            current_state<=S_IDLE;
            current_data_bit<=(OTHERS=>'0');
        ELSIF rising_edge(clk) THEN
            current_state<=next_state;
            current_data_bit<=next_data_bit;
        END IF;
    END PROCESS;
    
    --FSM (S_IDLE, S_START_BIT, S_DATA_BITS, S_PARITY_BIT, S_STOP_BIT1, S_STOP_BIT2);
    PROCESS(current_state, current_data_bit, tx_valid, bit_done) --Change: ALL for sensitivity list is not compatible with all simulators. Explicit description of the list
    BEGIN
        next_state<=current_state;
        next_data_bit<=current_data_bit;
        sample_data_in<='0';
        baudgen<='0';
        tx_out<='1'; --line is idle as default
        tx_ready<='1';
        CASE current_state IS
            WHEN S_IDLE=>
                --start transmission when there is a data ready
                IF tx_valid='1' THEN
                    next_state<=S_START_BIT;
                    sample_data_in<='1'; --register input data
                ELSE
                    next_state<=S_IDLE;
                END IF;
            
            WHEN S_START_BIT=>
                --send start bit (keep line at zero until bit frame ends)
                next_data_bit <= (OTHERS => '0'); --Change: Every time UART finishes with a tranmission, it has to reset the current_data_bit counter in order to start counting for the new transmission
                tx_ready<='0';
                tx_out<='0';
                baudgen<='1';
                IF bit_done='1' THEN
                    next_state<=S_DATA_BITS;
                ELSE
                    next_state<=S_START_BIT;
                END IF;
                
            WHEN S_DATA_BITS=>
                --start sending out bits
                tx_ready<='0';
                tx_out<=reg_tx_data(0); --UART transmits LSB first
                baudgen<='1';
                IF bit_done='1' THEN
                    next_data_bit<=current_data_bit + 1;
                    IF current_data_bit=target_data_bits THEN
                        IF parity_bit_en='1' THEN
                            next_state<=S_PARITY_BIT;
                        ELSE
                            next_state<=S_STOP_BIT1;
                        END IF;
                    ELSE
                        sample_data_in<='1';
                        next_state<=S_DATA_BITS;
                    END IF;
                END IF;
                
            WHEN S_PARITY_BIT=>
                --send out parity bit
                tx_ready<='0';
                baudgen<='1';
                tx_out<=parity_value;
                IF bit_done='1' THEN
                    next_state<=S_STOP_BIT1;
                ELSE
                    next_state<=S_PARITY_BIT;
                END IF;
            
            WHEN S_STOP_BIT1=>
                --send out stop bit 1
                tx_ready<='0';
                baudgen<='1';
                IF bit_done='1' THEN
                    IF stop_bits='0' THEN
                        next_state<=S_IDLE;
                    ELSE
                        next_state<=S_STOP_BIT2;
                    END IF;
                END IF; 
                
            WHEN S_STOP_BIT2=>
                tx_ready<='0';
                 --send out stop bit 2
                baudgen<='1';
                IF bit_done='1' THEN
                    next_state<=S_IDLE;
                    tx_ready<='1';
                ELSE
                    next_state<=S_STOP_BIT2;                 
                END IF;   
            WHEN OTHERS=>
                next_state<=S_IDLE;
             
        END CASE;
          
    END PROCESS;

END behavior;

