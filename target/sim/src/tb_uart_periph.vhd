-- **************************************************************************************
--	Filename:	tb_uart_rx_core.vhd
--	Project:	CNL_RISC-V
--  Version:	1.0
--	History:
--	Date:		23 December 2023
--
-- Copyright (C) 2024 CINI Cybersecurity National Laboratory
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
--	Testbench for the UART peripheral
--
-- **************************************************************************************

LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE work.Constants.ALL;
USE std.textio.ALL;

ENTITY tb_uart_periph IS
--  Port ( );
END tb_uart_periph;

ARCHITECTURE Behavioral OF tb_uart_periph IS
    --System signals
    SIGNAL clk_s, rst_s :  STD_LOGIC := '0';
    --Input signals
    SIGNAL address_s :  STD_LOGIC_VECTOR(3 DOWNTO 0);
    SIGNAL busDataIn_s : STD_LOGIC_VECTOR(7 DOWNTO 0);
    SIGNAL read_s, write_s, uart_rx_s :  STD_LOGIC; 
    --Output signals
    SIGNAL interrupt_s, uart_tx_s : STD_LOGIC;
    SIGNAL busDataOut_s : STD_LOGIC_VECTOR(7 DOWNTO 0);
    
    SIGNAL input_uart_periph :  STD_LOGIC_VECTOR(14 DOWNTO 0);
   
BEGIN

    --Generation of the clock
    clk_s <= NOT(clk_s) AFTER ClockPeriod/2;


    pattern: PROCESS
		FILE inputFile : text;		
		VARIABLE inputLine : line;
		VARIABLE inputBit  : bit;
	BEGIN
		file_open(inputFile, "uartPeriph_values.mem", read_mode);
		rst_s <= '1'; 
		WAIT FOR ClockPeriod;
		rst_s <= '0';
		
		WHILE NOT endfile(inputFile) LOOP
			readline(inputFile, inputline);
			FOR i IN inputline'RANGE LOOP
				read(inputline, inputbit);
				IF inputbit = '1' THEN		
				    input_uart_periph(15 - i) <= '1';
				ELSE
                    input_uart_periph(15 - i) <= '0';        
				END IF;
			END LOOP; 
	        WAIT FOR ClockPeriod; 
		END LOOP;
		file_close(inputFile);
		WAIT;
	END PROCESS pattern;
	
	address_s <= input_uart_periph(14 DOWNTO 11);
	busDataIn_s <= input_uart_periph(10 DOWNTO 3);
	read_s <= input_uart_periph(2);
	write_s <= input_uart_periph(1);
	uart_rx_s <= input_uart_periph(0);

    uart_peripheral : ENTITY work.uart 
        PORT MAP (
            --system signals
            clk => clk_s,
            rst => rst_s, 
            --input signals
            address => address_s,
            busDataIn => busDataIn_s,
            read => read_s,
            write => write_s,
            uart_rx => uart_rx_s,
            --output signals signals
            interrupt => interrupt_s,
            uart_tx => uart_tx_s,
            busDataOut => busDataOut_s
        );



END Behavioral;
