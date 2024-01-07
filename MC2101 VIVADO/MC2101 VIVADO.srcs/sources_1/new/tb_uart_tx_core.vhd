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

ENTITY tb_uart_tx_core IS
--  Port ( );
END tb_uart_tx_core;

--Test patterns are read from the uartRX_values.mem file
ARCHITECTURE test OF tb_uart_tx_core IS 

    --System signals
    SIGNAL clock_s, rst_s : STD_LOGIC := '0';
    --INPUT signals
    SIGNAL divisor_s : STD_LOGIC_VECTOR(15 DOWNTO 0);
    SIGNAL parity_bit_en_s, parity_type_s, stop_bits_s : STD_LOGIC;
    SIGNAL data_width_s : STD_LOGIC_VECTOR(1 DOWNTO 0);
    SIGNAL tx_data_i_s : STD_LOGIC_VECTOR(7 DOWNTO 0);
    --OUTPUT signals
    SIGNAL tx_ready_s, tx_out_s, tx_valid_s : STD_LOGIC; 
    
    SIGNAL configuration_uart :  STD_LOGIC_VECTOR(20 DOWNTO 0) := (OTHERS => '0'); -- divisor(16 bits) +  parity_bit_en_s(1 bit) + parity_type_s(1 bit) + stop_bits_s(1 bits) + data_width_s(2 bits) 
    
    SIGNAL transmission_uart :   STD_LOGIC_VECTOR(7 DOWNTO 0) := (OTHERS => '0');  
    

    
    
BEGIN

    --Generation of the clock
    clock_s <= NOT(clock_s) AFTER ClockPeriod/2;


    pattern: PROCESS
		FILE inputFile : text;		
		VARIABLE inputLine : line;
		VARIABLE inputBit  : bit;
	BEGIN
		file_open(inputFile, "uartTX_values.mem", read_mode);
		rst_s <= '1'; 
		tx_valid_s <= '1';
		WAIT FOR ClockPeriod;
		rst_s <= '0';
		
		WHILE NOT endfile(inputFile) LOOP
			readline(inputFile, inputline);
			FOR i IN inputline'RANGE LOOP
				read(inputline, inputbit);
				IF inputbit = '1' THEN		
					IF i > 21 then
					   transmission_uart(22 + 7 - i)<= '1';
					ELSE
					   configuration_uart(21 - i) <= '1';
					END IF;
				ELSE
                    IF i > 21 THEN
					   transmission_uart(22 + 7 - i)<= '0';
					ELSE
					   configuration_uart(21 - i) <= '0';
					END IF;
			         
				END IF;
			END LOOP; 
	        WAIT FOR ClockPeriod; --We have to wait until tx_valid_s is read in the IDLE state
	        tx_valid_s <= '0'; 
	        WAIT FOR ClockPeriod * (1 + 8 + 1 + 2); --Wait for 1 start bit + message(8 bits) + 1 parity bit + 2 start bits
	        tx_valid_s <= '1';
		END LOOP;
		file_close(inputFile);
		WAIT;
	END PROCESS pattern;

    divisor_s <= configuration_uart(20 DOWNTO 5);
    parity_bit_en_s <= configuration_uart(4);
    parity_type_s <= configuration_uart(3);
    stop_bits_s <= configuration_uart(2);
    data_width_s <= configuration_uart(1 DOWNTO 0);
    tx_data_i_s <= transmission_uart;
    --tx_valid_s <= '1'; --We assume to always have data ready to be transmitted
    
    
    uart_tx : ENTITY work.uart_tx_core
        PORT MAP(
	    --system signals
		clk => clock_s,
		rst => rst_s,
		--input signals
		divisor => divisor_s, --divisor value for baudrate
		parity_bit_en => parity_bit_en_s,  --enable for parity bit
		parity_type => parity_type_s,  --even(0) or odd parity check 
		data_width => data_width_s, --data bits in the frame can be on 5,6,7,8 bits
		stop_bits => stop_bits_s,  --number of stop bits (0 == 1 stop bit) (1 == 2 stop bits)
		tx_data_i => tx_data_i_s,  --data to be transmitted
		tx_valid => tx_valid_s, --some data is ready to be transmitted
		--output signals signals
		tx_ready => tx_ready_s, --transmitter ready for next data
		tx_out => tx_out_s  --TX line
    );
    

---ATTENTION:
---If one wants to simulate sending messages with a length less than 8 bits, he/she has to consider that the UART receives a message input of 8 bits coming from the FIFO
---Thus, the input should be of 8 bits anyway. Then, the UART will only consider a number of bits corresponding to the data_width.
---Example: Message to be transmitted: "10101"(5 bits) (data_width = "00")
---Then, one should define tx_data = "00010101"(3 zero bits + message to be transmitted). The UART will send the bits from the LSB(1) to the MSB(1) and will not tranmsit the 0's


END test;