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

    COMPONENT uart_controller IS   
	PORT (
	    clk         :IN STD_LOGIC;
	    rst         :IN STD_LOGIC;
	    chip_select :IN  STD_LOGIC;
		request     :IN  STD_LOGIC;
	    uart_read   :OUT STD_LOGIC;
	    uart_write  :OUT STD_LOGIC;
	    uart_ready  :OUT STD_LOGIC;
	    uart_resp   :OUT STD_LOGIC
	);
    END COMPONENT;
    
    SIGNAL chip_select: STD_LOGIC;
    SIGNAL request: STD_LOGIC;
    SIGNAL read, write: STD_LOGIC;
    
    COMPONENT uart IS 
	PORT (
	    --system signals
		clk            : IN  STD_LOGIC;
		rst            : IN  STD_LOGIC;
		--input signals
		address        : IN  STD_LOGIC_VECTOR(2 DOWNTO 0);
		busDataIn      : IN  STD_LOGIC_VECTOR(7 DOWNTO 0);
		read           : IN  STD_LOGIC;
		write          : IN  STD_LOGIC;
		uart_rx        : IN  STD_LOGIC; --async uart RX line
		--output signals signals
		interrupt      : OUT STD_LOGIC;
		uart_tx        : OUT STD_LOGIC; --async uart TX line
		busDataOut     : OUT STD_LOGIC_VECTOR(7 DOWNTO 0)
	);
    END COMPONENT;
    
    
 
BEGIN

    uart_periph: uart 
	PORT MAP(
		clk=>clk,
		rst=>rst,
		address=>haddr(2 DOWNTO 0),
		busDataIn=>hwrdata,
		read=>read,
		write=>write,
		uart_rx=>uart_rx,
		interrupt=>uart_interrupt,
		uart_tx=>uart_tx,
		busDataOut=>hrdata
	);
	
	uart_ctrl: uart_controller   
	PORT MAP(
	    clk=>clk,
	    rst=>rst,
	    chip_select=>hselx,
		request=>hwrite,
	    uart_read=>read,
	    uart_write=>write,
	    uart_ready=>hready,
	    uart_resp=>hresp
	);

END behavior;
