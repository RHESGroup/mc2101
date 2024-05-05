-- **************************************************************************************
--	Filename:	tb_uart_fifo.vhd
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
--	Testbench for the fifo used in UART
--
-- **************************************************************************************

LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE work.Constants.ALL;
USE std.textio.ALL;

ENTITY tb_uart_fifo IS
--  Port ( );
END tb_uart_fifo;

ARCHITECTURE Behavioral OF tb_uart_fifo IS

    --System signals
    SIGNAL clk_s, rst_s :  STD_LOGIC := '0';
    --Input signals
    SIGNAL clear_s, read_request_s, write_request_s :  STD_LOGIC := '0';
    SIGNAL data_in_s :  STD_LOGIC_VECTOR(DATA_WIDTHFIFO - 1 DOWNTO 0) := (OTHERS => '0');
    --Output signals
    SIGNAL elements_s : STD_LOGIC_VECTOR(LOG_FIFO_D DOWNTO 0);
    SIGNAL data_out_s : STD_LOGIC_VECTOR(DATA_WIDTHFIFO-1 DOWNTO 0);
    SIGNAL fifo_empty_s, fifo_full_s :  STD_LOGIC;
    
    SIGNAL input_fifo :  STD_LOGIC_VECTOR(DATA_WIDTHFIFO - 1 + 3 DOWNTO 0); --data_in_s + clear_s(1 bit) + read_request_s(1 bit) + write_request_s(1 bit)
    
    
BEGIN


    --Generation of the clock
    clk_s <= NOT(clk_s) AFTER ClockPeriod/2;


    pattern: PROCESS
		FILE inputFile : text;		
		VARIABLE inputLine : line;
		VARIABLE inputBit  : bit;
	BEGIN
		file_open(inputFile, "uartFIFO_values.mem", read_mode);
		rst_s <= '1'; 
		WAIT FOR ClockPeriod;
		rst_s <= '0';
		
		WHILE NOT endfile(inputFile) LOOP
			readline(inputFile, inputline);
			FOR i IN inputline'RANGE LOOP
				read(inputline, inputbit);
				IF i < 12 THEN
                    IF inputbit = '1' THEN		
                        input_fifo(DATA_WIDTHFIFO + 3 - i) <=  '1';
                    ELSE
                        input_fifo(DATA_WIDTHFIFO + 3 - i) <=  '0';
                    END IF;
                END IF;
			END LOOP; 
	        WAIT FOR ClockPeriod;
		END LOOP;
		file_close(inputFile);
		WAIT;
	END PROCESS pattern;
	
	
    data_in_s <= input_fifo(DATA_WIDTHFIFO - 1 + 3 DOWNTO 3);
    clear_s <= input_fifo(2);
    read_request_s <= input_fifo(1);
    write_request_s <= input_fifo(0);


    uartt_fifo: ENTITY work.fifo
        GENERIC MAP(
            DATA_WIDTHFIFO => DATA_WIDTHFIFO,
            FIFO_DEPTH => FIFO_DEPTH,
            LOG_FIFO_D => LOG_FIFO_D
        )
        PORT MAP ( 
            --system signals
            clk => clk_s,
            rst => rst_s,
            --input signals
            clear => clear_s,
            data_in => data_in_s,
            read_request => read_request_s,
            write_request => write_request_s,
            --output signals 
            elements => elements_s,   --#elements in the queue
            data_out => data_out_s,   --data OUT
            fifo_empty => fifo_empty_s, --is fifo empty?
            fifo_full => fifo_full_s --is fifo full
	   );

END Behavioral;
