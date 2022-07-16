-- **************************************************************************************
--	Filename:	tb_fifo.vhd
--	Project:	CNL_RISC-V
--  Version:	1.0
--	History:
--	Date:		10 Jul 2022
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
--	testbench for FIFO data structure
--
-- **************************************************************************************

LIBRARY IEEE;
LIBRARY STD;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.NUMERIC_STD.ALL;

ENTITY tb_fifo IS 
END tb_fifo;


ARCHITECTURE tb OF tb_fifo IS
    COMPONENT fifo IS 
    GENERIC (
        DATA_WIDTH:  INTEGER:=32;
        FIFO_DEPTH:  INTEGER:=16;
        LOG_FIFO_D:  INTEGER:=4
    );
	PORT (
	    --system signals
		clk             : IN  STD_LOGIC;
		rst             : IN  STD_LOGIC;
		--input signals
		clear           : IN  STD_LOGIC;    --clear the FIFO
		data_in         : IN  STD_LOGIC_VECTOR(DATA_WIDTH-1 DOWNTO 0); --data IN
		read_request    : IN  STD_LOGIC;  --read operation reequest on the FIFO
		write_request   : IN  STD_LOGIC;  --write operation reequest on the FIFO
		--output signals signals
		elements        : OUT STD_LOGIC_VECTOR(LOG_FIFO_D DOWNTO 0);  --#elements in the queue
		data_out        : OUT STD_LOGIC_VECTOR(DATA_WIDTH-1 DOWNTO 0);  --data OUT
		fifo_empty      : OUT STD_LOGIC; --is fifo empty?
		fifo_full       : OUT STD_LOGIC --is fifo full
	);
    END COMPONENT;
    
    SIGNAL clk, rst, clear, fifo_e, fifo_f, read, write: STD_LOGIC;
    SIGNAL din, dout: STD_LOGIC_VECTOR(7 DOWNTO 0);
    SIGNAL n_elements: STD_LOGIC_VECTOR(3 DOWNTO 0);
    
    CONSTANT MAX_ELEMENTS: INTEGER:=8;
    
    
BEGIN

    UUT_FIFO: fifo
    GENERIC MAP(
        DATA_WIDTH=>8,
        FIFO_DEPTH=>8,
        LOG_FIFO_D=>3
    )
	PORT MAP(
		clk=>clk,
		rst=>rst,
		clear=>clear,
		data_in=>din,
		read_request=>read,
		write_request=>write,
		elements=>n_elements,
		data_out=>dout,
		fifo_empty=>fifo_e,
		fifo_full=>fifo_f
	);

    PROCESS
    BEGIN
        clk<='0';
        WAIT FOR 25 ns;
        clk<='1';
        WAIT FOR 25 ns;
    END PROCESS;
    
    PROCESS
    BEGIN
        rst<='0';
        WAIT FOR 30 ns;
        rst<='1';
        WAIT FOR 30 ns;
        rst<='0';
        WAIT FOR 4 ns;
        clear<='0';
        din<=(OTHERS=>'0');
        read<='0';
        write<='0';
        WAIT FOR 20 ns;
        --fill the queue with all ones
        write<='1';
        din<=(OTHERS=>'1');
        WAIT UNTIL fifo_f='1';
        write<='0';
        din<=(OTHERS=>'0');
        --the queue is full, no more write operations should be allowed
        WAIT UNTIL rising_edge(clk);
        WAIT UNTIL rising_edge(clk);
        WAIT UNTIL rising_edge(clk);
        write<='1';
        WAIT UNTIL rising_edge(clk);
        WAIT UNTIL rising_edge(clk);
        WAIT UNTIL rising_edge(clk);
        WAIT UNTIL rising_edge(clk);
        WAIT UNTIL rising_edge(clk);
        WAIT UNTIL rising_edge(clk);
        WAIT UNTIL rising_edge(clk);
        write<='0';
        --free the queue by reading until empty
        read<='1';
        WAIT UNTIL fifo_e='1';
        --the queue is empty, no more read operations should be allowed
        read<='0';
        WAIT UNTIL rising_edge(clk);
        WAIT UNTIL rising_edge(clk);
        WAIT UNTIL rising_edge(clk);
        read<='1';
        WAIT UNTIL rising_edge(clk);
        WAIT UNTIL rising_edge(clk);
        WAIT UNTIL rising_edge(clk);
        WAIT UNTIL rising_edge(clk);
        WAIT UNTIL rising_edge(clk);
        WAIT UNTIL rising_edge(clk);
        WAIT UNTIL rising_edge(clk);
        read<='0';
        WAIT UNTIL rising_edge(clk);
        WAIT UNTIL rising_edge(clk);
        WAIT UNTIL rising_edge(clk);
        --fill the queue until elements = max_elements -1
        write<='1';
        din<=X"AA";
        WAIT UNTIL TO_INTEGER(UNSIGNED(n_elements)) = MAX_ELEMENTS-1;
        --perform write, read in sequence
        read<='1';
        write<='1';
        din<=(OTHERS=>'0');
        WAIT FOR 500 ns;
        WAIT UNTIL rising_edge(clk);
        read<='0';
        write<='0';
        --clear the queue
        clear<='1';
        WAIT;
    END PROCESS;
       
END tb;
