-- **************************************************************************************
--	Filename:	uart_bus_wrap.vhd
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
--	uart hbus peripheral wrapper
--
-- **************************************************************************************
LIBRARY IEEE;
LIBRARY STD;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.NUMERIC_STD.ALL;


ENTITY uart_bus_wrap IS 
    GENERIC (
		busDataWidth      : INTEGER := 8;
		busAddressWidth   : INTEGER := 32
	);
	PORT (
	    --system signals
		clk           : IN  STD_LOGIC;
		rst           : IN  STD_LOGIC;
		--master driven signals
		htrans        : IN  STD_LOGIC_VECTOR(1 DOWNTO 0);
		hselx         : IN  STD_LOGIC;
		hwrite        : IN  STD_LOGIC;
		hwrdata       : IN  STD_LOGIC_VECTOR(busDataWidth-1 DOWNTO 0);
		haddr         : IN  STD_LOGIC_VECTOR(busAddressWidth-1 DOWNTO 0);
		--slave driven signals
		hrdata        : OUT STD_LOGIC_VECTOR(busDataWidth-1 DOWNTO 0);
		hready        : OUT STD_LOGIC;
		hresp         : OUT STD_LOGIC;
		--slave external signals
		uart_interrupt: OUT STD_LOGIC;
		uart_rx       : IN  STD_LOGIC;
		uart_tx       : OUT STD_LOGIC
	);
END uart_bus_wrap;


ARCHITECTURE behavior OF uart_bus_wrap IS
    
    SIGNAL read, write: STD_LOGIC;
    
    
 
BEGIN

    uart_periph: ENTITY work.uart 
	PORT MAP(
		clk=>clk,
		rst=>rst,
		--input signals
		address=>haddr(3 DOWNTO 0), --The UART is controlled through a set of registers addressable with 4 bits--NEw change
		busDataIn=>hwrdata,
		read=>read,
		write=>write,
		uart_rx=>uart_rx,
		--output signals
		interrupt=>uart_interrupt,
		uart_tx=>uart_tx,
		busDataOut=>hrdata
	);
	
	uart_ctrl: ENTITY work.uart_controller   
	PORT MAP(
	    clk=>clk,
	    rst=>rst,
	    --Input signals
	    chip_select=>hselx,
		request=>hwrite,
		--Output signals
	    uart_read=>read,
	    uart_write=>write,
	    uart_ready=>hready,
	    uart_resp=>hresp
	);

END behavior;
