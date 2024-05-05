-- **************************************************************************************
--	Filename:	tb_uart_rx_core.vhd
--	Project:	CNL_RISC-V
--  Version:	1.0
--	History:
--	Date:		23 December 2023
--
-- Copyright (C) 2023 CINI Cybersecurity National Laboratory
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
--	Testbench for the uart rx core
--
-- **************************************************************************************

LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE work.Constants.ALL;
USE std.textio.ALL;

ENTITY tb_uart_rx_core IS
--  Port ( );
END tb_uart_rx_core;


--Test patterns are read from the uartRX_values.mem file
ARCHITECTURE test OF tb_uart_rx_core IS 

   
    --System signals
    SIGNAL clock_s, rst_s : STD_LOGIC := '0';
    --INPUT signals
    SIGNAL divisor_s : STD_LOGIC_VECTOR(15 DOWNTO 0) := (OTHERS => '0');
    SIGNAL prescaler_s : STD_LOGIC_VECTOR(3 DOWNTO 0) := (OTHERS => '0');
    SIGNAL parity_bit_en_s, parity_type_s, stop_bits_s, rx_in_async_s : STD_LOGIC := '0';
    SIGNAL data_width_s : STD_LOGIC_VECTOR(1 DOWNTO 0);
    --OUTPUT signals
    SIGNAL break_interrupt_s, frame_error_s, parity_error_s, rx_valid_s : STD_LOGIC := '0'; 
    SIGNAL rx_data_buffer_s :  STD_LOGIC_VECTOR(7 DOWNTO 0) := (OTHERS => '0');
    
    SIGNAL configuration_uart :  STD_LOGIC_VECTOR(24 DOWNTO 0) := (OTHERS => '0'); -- divisor(16 bits) + prescaler(4 bits) +  parity_bit_en_s(1 bit) + parity_type_s(1 bit) + stop_bits_s(1 bits) + data_width_s(2 bits) 
    
    SIGNAL transmission_uart :   STD_LOGIC := '1'; --start bit(1 bit) + message(maximum 8 bit) + parity bit(1 bit) + stop bits(maximum 2 bits)
    
    
BEGIN

    --Generation of the clock
    clock_s <= NOT(clock_s) AFTER ClockPeriod/2;


    pattern: PROCESS
		FILE inputFile : text;		
		VARIABLE inputLine : line;
		VARIABLE inputBit  : bit;
	BEGIN
		file_open(inputFile, "uartRX_values.mem", read_mode);
		rst_s <= '1'; 
		WAIT FOR ClockPeriod;
		rst_s <= '0';
		WHILE NOT endfile(inputFile) LOOP
			readline(inputFile, inputline);
			FOR i IN inputline'RANGE LOOP
				read(inputline, inputbit);
				IF inputbit = '1' THEN		
					IF i > 25 then
					   transmission_uart<= '1';
					ELSE
					   configuration_uart(25 - i) <= '1';
					END IF;
				ELSE
                    IF i > 25 THEN
					   transmission_uart<= '0';
					ELSE
					   configuration_uart(25 - i) <= '0';
					END IF;
			         
				END IF;
		    WAIT FOR ClockPeriod;
			END LOOP; 	
		END LOOP;
		file_close(inputFile);
		WAIT;
	END PROCESS pattern;

    divisor_s <= configuration_uart(24 DOWNTO 9);
    prescaler_s <= configuration_uart(8 DOWNTO 5);
    parity_bit_en_s <= configuration_uart(4);
    parity_type_s <= configuration_uart(3);
    stop_bits_s <= configuration_uart(2);
    data_width_s <= configuration_uart(1 DOWNTO 0);
    
    rx_in_async_s <= transmission_uart;
    
    
    uart_rx : ENTITY work.uart_rx_core
        PORT MAP(
    	    --system signals
		clk => clock_s,
		rst => rst_s,
		--INPUTS
		divisor => divisor_s, --divisor value for baudrate 
		prescaler => prescaler_s, --prescaler divisor for baudrate
		parity_bit_en => parity_bit_en_s,  --enable for parity bit
		parity_type => parity_type_s,  --even(0) or odd(1) parity check ---Opposite values with respect to the UART Protocol
		data_width => data_width_s, --data bits in the frame can be on 5,6,7,8 bits
		stop_bits => stop_bits_s, --number of stop bits (0 == 1 stop bit) (1 == 2 stop bits)
		rx_in_async => rx_in_async_s, --RX line --It receives one character at a time
		--OUTPUTS
		break_interrupt => break_interrupt_s, --break interrupt
		frame_error => frame_error_s,  --frame error
		parity_error => parity_error_s, --parity error
		rx_data_buffer => rx_data_buffer_s, --registered data
		rx_valid => rx_valid_s --data correctly sampled
    );



END test;



