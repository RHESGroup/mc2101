-- **************************************************************************************
--	Filename:	altera_mem_mc2101_bus_wrap.vhd
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
--	altera dual port ram to mc2101 bus wrapper
--
-- **************************************************************************************
LIBRARY IEEE;
LIBRARY STD;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.NUMERIC_STD.ALL;


ENTITY ssram_bus_wrap IS
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
		hresp         : OUT STD_LOGIC
	);
END ssram_bus_wrap;


ARCHITECTURE behavior OF ssram_bus_wrap IS

    --ssram
    COMPONENT altera_mem_16384x8_dp IS
	PORT
	(
		data		: IN STD_LOGIC_VECTOR (7 DOWNTO 0);
		rdaddress	: IN STD_LOGIC_VECTOR (13 DOWNTO 0);
		rdclock		: IN STD_LOGIC ;
		rden		: IN STD_LOGIC  := '1';
		wraddress	: IN STD_LOGIC_VECTOR (13 DOWNTO 0);
		wrclock		: IN STD_LOGIC  := '1';
		wren		: IN STD_LOGIC  := '0';
		q		    : OUT STD_LOGIC_VECTOR (7 DOWNTO 0)
	);
    END COMPONENT;
    
    SIGNAL readMem: STD_LOGIC;
    SIGNAL writeMem: STD_LOGIC;
    SIGNAL dataOut: STD_LOGIC_VECTOR (busDataWidth -1 DOWNTO 0);
    SIGNAL ready: STD_LOGIC;
    --The actual physical size of the ram is 2**14 (16 KB)
    CONSTANT PHSIZE: integer:=14;
    SIGNAL phyaddr: STD_LOGIC_VECTOR(PHSIZE-1 DOWNTO 0);
    
    --controller
    COMPONENT altera_mem_mc2101_controller IS 
	PORT (
	    --system signals
		clk           : IN  STD_LOGIC;
		rst           : IN  STD_LOGIC;
		--input
		chip_select   : IN  STD_LOGIC;
		request       : IN  STD_LOGIC;
		--output
		memRead       : OUT STD_LOGIC;
		memWrite      : OUT STD_LOGIC;
		memResponse   : OUT STD_LOGIC;
		memReady      : OUT STD_LOGIC
	);
    END COMPONENT;
    
    SIGNAL chip_select: STD_LOGIC;
    SIGNAL request: STD_LOGIC;
    
    
BEGIN

    altera_memory_2p: altera_mem_16384x8_dp
	PORT MAP(
		data		=>hwrdata,
		rdaddress	=>phyaddr,
		rdclock		=>NOT(clk),
		rden		=>readMem,
		wraddress	=>phyaddr,
		wrclock		=>clk,
		wren		=>writeMem,
		q		    =>dataOut	   
	);
    
    controller: altera_mem_mc2101_controller 
	PORT MAP(
		clk            =>clk,
		rst            =>rst,
		chip_select    =>hselx,
		request        =>hwrite,
		memRead        =>readMem,
		memWrite       =>writeMem,
		memResponse    =>hresp, 
		memReady       =>hready
	);

    hrdata   <= dataOut;
    
    --Viritual address to physical address
    PROCESS(haddr)
    BEGIN
        IF haddr(20)='1' THEN
            --r/w to stack or data
            phyaddr<='1' & haddr(PHSIZE-2 DOWNTO 0);
        ELSE
            phyaddr<=haddr(PHSIZE-1 DOWNTO 0);
        END IF;
    END PROCESS;

END behavior;
