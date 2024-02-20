-- **************************************************************************************
--	Filename:	uart_rx_core.vhd
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
--	uart receiver control and shift register
--
-- **************************************************************************************
LIBRARY IEEE;
LIBRARY STD;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.NUMERIC_STD.ALL;

ENTITY uart_rx_core IS 
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
		rx_in_async     : IN  STD_LOGIC; --RX line
		--output signals
		break_interrupt : OUT STD_LOGIC; --break interrupt
		frame_error     : OUT STD_LOGIC; --frame error
		parity_error    : OUT STD_LOGIC; --parity error
		rx_data_buffer  : OUT STD_LOGIC_VECTOR(7 DOWNTO 0); --registered data
		rx_valid        : OUT STD_LOGIC --data correctly sampled
	);
END uart_rx_core;

--TODO: check if BI are correct with respect to UART 16550 specifications

ARCHITECTURE behavior OF uart_rx_core IS
    
    SIGNAL read: STD_LOGIC;
    SIGNAL data_received : STD_LOGIC_VECTOR(7 DOWNTO 0);

    --flag used to detect the falling edge of the start bit
    SIGNAL rx_line_fall: STD_LOGIC;
    
    --cascade of 3 FF used to synchronize the async RX input line
    SIGNAL rx_line_sync: STD_LOGIC_VECTOR(2 DOWNTO 0);
    
    --receiver FSM states
    TYPE statetype IS (S_IDLE, S_START_BIT, S_DATA_BITS, S_PARITY_CHECK, S_STOP_1, S_STOP_2);
    SIGNAL current_state, next_state: statetype;
    
    --baudrate generator signal (frequency divider)
    --sampling window is in the half of a bit frame
    --baudrate is BR=fck/(DIVISOR + 1)
    SIGNAL count : UNSIGNED(15 DOWNTO 0);
    SIGNAL sample: STD_LOGIC;
    SIGNAL half_divisor : UNSIGNED(15 downto 0);
    
    --signal that indicates that we are inside the start bit
    SIGNAL start_bit: STD_LOGIC;
    
    --shift register
    SIGNAL current_data, next_data: STD_LOGIC_VECTOR(7 DOWNTO 0);
    
    --frame data bit counter
    SIGNAL current_data_bit, next_data_bit: STD_LOGIC_VECTOR(2 DOWNTO 0);
    
    --number of data bits to be sampled
    SIGNAL target_data_bits: STD_LOGIC_VECTOR(2 DOWNTO 0);
    
    --parity signal
    SIGNAL parity_value: STD_LOGIC;
    
    --parity error (LATCH), parity error is hold until stop bit asserts rx_valid
    SIGNAL parity_bit_received: STD_LOGIC;
    
    --signals used to capture and clear of parity bit
    SIGNAL clear_parity_bit_received: STD_LOGIC;
    SIGNAL sample_parity_bit_received: STD_LOGIC;
    
    --used to enable baudrate generator
    SIGNAL baudgen: STD_LOGIC;
    
    
BEGIN

    half_divisor <= '0' & UNSIGNED(divisor(15 DOWNTO 1)); 

    target_data_bits <= "100" WHEN data_width="00" ELSE
                        "101" WHEN data_width="01" ELSE
                        "110" WHEN data_width="10" ELSE
                        "111";

    --RX synchronizer (111 = IDLE STATE)
    PROCESS(clk, rst)
    BEGIN
        IF rst='1' THEN
            rx_line_sync <= (OTHERS=>'1');
        ELSIF rising_edge(CLK) THEN
            rx_line_sync <= rx_line_sync(1 DOWNTO 0) & rx_in_async;
        END IF;
    END PROCESS;
    
    --falling edge detector
    rx_line_fall <= rx_line_sync(2) AND NOT(rx_line_sync(1));
    
    
    --We want to avoid oversampling in UART:
    --1)We wait until the incoming signal becomes 0(start bit = '0' - rx_line_fall = '1'), then we start the sampling counter
    --2)When tick counter reaches 7(middle of the start bit), we clear the tick counter and restart. We want to sample at the middle of the bit
    --3)When tick counter reaches 15(middle of data bit), we shift the value into the register and restart the tick counter.
    --4) We repeat step 3) more times for the remaining bits.
    
    
    
    --baudrate generator (assert sample signal [like a delta] at half of the bit frame)
    PROCESS(clk, rst)
    BEGIN
        IF (rst='1' OR baudgen='0') THEN
            count<=(OTHERS=>'0');
            sample<='0';
        ELSIF rising_edge(clk) THEN
            IF ( start_bit='1' AND (count=half_divisor) ) THEN --To follow step 2)
                sample<='1';
                count<=(OTHERS=>'0');
            ELSIF ( start_bit='0' AND (count=UNSIGNED(divisor)) ) THEN --To follow step 3)
                sample<='1';
                count<=(OTHERS=>'0');
            ELSE
                sample<='0';
                count<=count + 1;
            END IF; 
        END IF;
    END PROCESS;
    
    --PROCESS related to the reading of the characters
    PROCESS(clk, rst) 
    BEGIN
        IF rst = '1' THEN
            data_received <= (OTHERS => '0');
        ELSIF rising_edge(clk) THEN
            IF read = '1' THEN
                data_received <= rx_line_sync(2) & data_received(7 DOWNTO 1);
            END IF;
        END IF;
    END PROCESS;
    
    --FSM registers update
    PROCESS(clk,rst)
    BEGIN
        IF rst='1' THEN
            current_state<=S_IDLE;
            current_data<=(OTHERS=>'0'); 
            current_data_bit<=(OTHERS=>'0');
        ELSIF rising_edge(clk) THEN
            current_state<=next_state;
            current_data_bit<=next_data_bit;
            current_data<=next_data;
        END IF;
    END PROCESS;
    
    --FSM  (S_IDLE, S_START_BIT, S_DATA_BITS, S_PARITY_CHECK, S_STOP_1, S_STOP_2);
    PROCESS(current_state, current_data_bit, current_data, rx_line_fall, sample, data_width, rx_line_sync)
    BEGIN
        start_bit<='0';
        next_data<=current_data;
        next_data_bit<=current_data_bit;
        next_state<=current_state;
        rx_valid<='0';
        baudgen<='0';
        clear_parity_bit_received<='0';
        sample_parity_bit_received<='0';
        read <= '0';
        
        CASE current_state IS
            WHEN S_IDLE=>
                clear_parity_bit_received<='1';
                --move to S_START_BIT when falling detected
                IF rx_line_fall='1' THEN
                    next_state<=S_START_BIT;
                    start_bit<='1';
                    baudgen<='1';
                ELSE
                    next_state<=S_IDLE;
                END IF;
                
            WHEN S_START_BIT=>
                baudgen<='1';
                start_bit<='1';
                --when first sample point is asserted the FSM can move to S_DATA_BITS and be ready to sample data
                IF sample='1' THEN
                    --start bit acceptance
                    IF rx_line_sync(2)='0' THEN
                        next_state<=S_DATA_BITS;
                        read <= '1';
                    ELSE
                        next_state<=S_IDLE;
                    END IF;
                ELSE
                    next_state<=current_state;
                END IF;
                
            WHEN S_DATA_BITS=>
                --now at each sample point the data is read
                baudgen<='1';
                IF sample='1' THEN
                    next_data_bit<=STD_LOGIC_VECTOR(UNSIGNED(current_data_bit) + 1);
                    read <= '1';    
                    IF current_data_bit=target_data_bits THEN
                        next_data_bit<=(OTHERS=>'0');
                        IF parity_bit_en='1' THEN
                            next_state<=S_PARITY_CHECK;
                        ELSE
                            next_state<=S_STOP_1;
                        END IF;
                        
                    ELSE
                        next_state<=S_DATA_BITS;
                    END IF;
                END IF;
                
            WHEN S_PARITY_CHECK=>
                baudgen<='1';
                IF sample='1' THEN
                    sample_parity_bit_received<='1';
                    next_state<=S_STOP_1;
                ELSE
                    next_state<=S_PARITY_CHECK;
                END IF;
                
            WHEN S_STOP_1=>
                baudgen<='1';
                IF sample='1' THEN
                    --save received stop bit 1 (transmission is considered finished)
                    rx_valid<='1';
                    IF stop_bits='0' THEN
                        next_state<=S_IDLE;
                    ELSE
                        next_state<=S_STOP_2;
                    END IF;
                ELSE
                    next_state<=S_STOP_1;
                END IF;
            
            WHEN S_STOP_2=>
                baudgen<='1';
                IF sample='1' THEN
                    next_state<=S_IDLE;
                ELSE
                    next_state<=S_STOP_2;
                END IF;                 
        END CASE;
    END PROCESS;
    
    
    --parity value computation 
    parity_value <= current_data(7) XOR 
                    current_data(6) XOR 
                    current_data(5) XOR 
                    current_data(4) XOR 
                    current_data(3) XOR 
                    current_data(2) XOR 
                    current_data(1) XOR 
                    current_data(0) XOR (NOT parity_type);
    
    
    rx_data_buffer <= current_data; 
    
    --errors computation
    
    -- PARITY ERROR
    PROCESS(clk, rst)
    BEGIN
        IF (rst='1' OR clear_parity_bit_received='1') THEN
            parity_bit_received<='0';
            parity_error<='0';
        ELSIF rising_edge(CLK) THEN
            IF sample_parity_bit_received='1' THEN
                parity_bit_received<=rx_line_sync(2);
                parity_error<=rx_line_sync(2) XOR parity_value;
            END IF;
        END IF;
    END PROCESS;
    
    

    -- FRAME ERROR
    frame_error <= '1' when current_state=S_STOP_1 AND  
                            rx_line_sync(2)='0' AND
                            sample='1'
                            ELSE '0';
    
    -- BREAK INTERRUPT
    break_interrupt <= '1' WHEN parity_bit_received = '0' AND 
                                current_state=S_STOP_1 AND  
                                rx_line_sync(2)='0' AND
                                sample='1' AND
                                current_data = "00000000" 
                           ELSE '0';
        
    
END behavior;

