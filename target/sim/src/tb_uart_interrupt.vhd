-- **************************************************************************************
--	Filename:	tb_uart_interrupt.vhd
--	Project:	CNL_RISC-V
--  Version:	1.0
--	History:
--	Date:		8 January 2024
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
--	Testbench for the interrupt controller of the UART
--
-- **************************************************************************************
----------------------------------------------------------


LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE work.Constants.ALL;
USE std.textio.ALL;

ENTITY tb_uart_interrupt IS
--  Port ( );
END tb_uart_interrupt;

ARCHITECTURE Behavioral OF tb_uart_interrupt IS

    --System signals
    SIGNAL clk_s, rst_s : STD_LOGIC := '0';
    --Input signals
    SIGNAL IER_s : STD_LOGIC_VECTOR(7 DOWNTO 0) := (OTHERS => '0');
    SIGNAL rx_fifo_trigger_lv_s : STD_LOGIC_VECTOR(1 DOWNTO 0) := (OTHERS => '0');
    SIGNAL rx_elements_s : STD_LOGIC_VECTOR(LOG_FIFO_D DOWNTO 0) := (OTHERS => '0');
    SIGNAL tx_elements_s : STD_LOGIC_VECTOR(LOG_FIFO_D DOWNTO 0) := (OTHERS => '0');
    SIGNAL rx_line_error_s, interrupt_clear_s, char_timeout_s : STD_LOGIC := '0';
    --Output signals 
    SIGNAL interrupt_s :  STD_LOGIC;
    SIGNAL interrupt_isr_code_s :  STD_LOGIC_VECTOR(3 DOWNTO 0);
 
    SIGNAL input_interrupt : STD_LOGIC_VECTOR((2 * (LOG_FIFO_D)) + 1 + 13 DOWNTO 0); --rx_elements_s + tx_elements_s + IER_s(8 bits) + rx_line_error_s(1 bit) + interrupt_clear_s(1 bit) + char_timeout_s(1 bit) 
    
BEGIN

    --Generation of the clock
    clk_s <= NOT(clk_s) AFTER ClockPeriod/2;


    pattern: PROCESS
		FILE inputFile : text;		
		VARIABLE inputLine : line;
		VARIABLE inputBit  : bit;
	BEGIN
		file_open(inputFile, "uartINTERRUPT_values.mem", read_mode);
		rst_s <= '1'; 
		WAIT FOR ClockPeriod;
		rst_s <= '0';
		
		WHILE NOT endfile(inputFile) LOOP
			readline(inputFile, inputline);
			FOR i IN inputline'RANGE LOOP
				read(inputline, inputbit);
				IF i < 24 THEN
                    IF inputbit = '1' THEN		
                        input_interrupt((2 * (LOG_FIFO_D)) + 2 + 13 - i) <=  '1';
                    ELSE
                        input_interrupt((2 * (LOG_FIFO_D)) + 2 + 13 - i) <=  '0';
                    END IF;
                END IF;
			END LOOP; 
	        WAIT FOR ClockPeriod;
		END LOOP;
		file_close(inputFile);
		WAIT;
	END PROCESS pattern;
	
    rx_elements_s <= input_interrupt((2 * (LOG_FIFO_D)) + 2 + 13 - 1 DOWNTO (2 * (LOG_FIFO_D)) + 2 + 13 - 1  - LOG_FIFO_D);
    tx_elements_s <= input_interrupt( (2 * (LOG_FIFO_D)) + 2 + 13 - 1  - LOG_FIFO_D - 1  DOWNTO (2 * (LOG_FIFO_D)) + 2 + 13 - 1 - LOG_FIFO_D - 1 - LOG_FIFO_D);
    IER_s <= input_interrupt(12 DOWNTO 5);
    rx_fifo_trigger_lv_s <= input_interrupt(4 DOWNTO 3);
    rx_line_error_s <= input_interrupt(2);
    interrupt_clear_s <= input_interrupt(1);
    char_timeout_s <= input_interrupt(0);


    interrupt_controller: ENTITY work.uart_interrupt
        GENERIC MAP(
            FIFO_DEPTH =>FIFO_DEPTH,
            LOG_FIFO_D =>LOG_FIFO_D
        )
        PORT MAP(
            --system signals
            clk => clk_s,
            rst => rst_s,
            --INPUTS
            IER => IER_s, --Interrupt Enable Register: RLS, THRe, DR enables. Enables each of the possible interrupt sources
            rx_fifo_trigger_lv => rx_fifo_trigger_lv_s,  --Receiver fifo trigger level
            rx_elements => rx_elements_s, --#elements in rx fifo
            tx_elements => tx_elements_s, --#elements in tx fifo
            rx_line_error => rx_line_error_s, 
            interrupt_clear => interrupt_clear_s, 
            char_timeout => char_timeout_s,
            --OUTPUTS
            interrupt => interrupt_s, 
            interrupt_isr_code => interrupt_isr_code_s --id of the interrupt raised
        );


END Behavioral;
