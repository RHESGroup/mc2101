-- **************************************************************************************
--	Filename:	ssram_bus_wrap.vhd
--	Project:	CNL_RISC-V
--  Version:	1.0
--	History:
--	Date:		3 April 2024
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
--	BRAM wrapper
--
-- **************************************************************************************
LIBRARY IEEE;
LIBRARY STD;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.NUMERIC_STD.ALL;


ENTITY Mem_wrapper IS
	GENERIC (
		busDataWidth      : INTEGER := 8;
		busAddressWidth   : INTEGER := 32;
		Physical_size     : INTEGER := 14
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
		---BRAM connections
        data_from_BRAM: IN STD_LOGIC_VECTOR(busDataWidth-1 DOWNTO 0);
	    data_to_BRAM  : OUT STD_LOGIC_VECTOR(busDataWidth-1 DOWNTO 0); 
	    address_bram  : OUT STD_LOGIC_VECTOR(Physical_size-1 DOWNTO 0);
	    memRead       : OUT STD_LOGIC;
	    memWrite      : OUT STD_LOGIC
	);
END Mem_wrapper;


ARCHITECTURE behavior OF Mem_wrapper IS

    --The actual physical size of the ram is 2**14 (16 KB)
    SIGNAL phyaddr: STD_LOGIC_VECTOR(Physical_size-1 DOWNTO 0);
    
    --controller
    COMPONENT bram_controller IS 
	PORT (
	    --system signals
		clk           : IN  STD_LOGIC;
		rst           : IN  STD_LOGIC;
		--input
		chip_select   : IN  STD_LOGIC;
		request       : IN  STD_LOGIC;
		--output
		memWrite      : OUT STD_LOGIC;
		memRead       : OUT STD_LOGIC;
		memResponse   : OUT STD_LOGIC;
		memReady      : OUT STD_LOGIC
	);
    END COMPONENT;
    
    SIGNAL internal_MC2101_BRAM, internal_BRAM_MC2101  : STD_LOGIC_VECTOR(busDataWidth-1 DOWNTO 0); 
            
BEGIN

    controller: bram_controller 
	PORT MAP(
            --system signals
        clk => clk,
        rst => rst,
        --input
        chip_select => hselx,
        request => hwrite,
        --output
        memWrite => memWrite,
        memRead => memRead,
        memResponse => hresp,
        memReady => hready	

	);

    --Internal connections
    internal_MC2101_BRAM <= hwrdata; 
    data_to_BRAM <= internal_MC2101_BRAM; --This goes to the BRAM
    
    internal_BRAM_MC2101 <= data_from_BRAM;
    hrdata <= internal_BRAM_MC2101; --This comes from the BRAM

   
    --Virtual address to physical address
    PROCESS(haddr)
    BEGIN
        IF haddr(20)='1' THEN
            --r/w to stack or data
            phyaddr<='1' & haddr(Physical_size-2 DOWNTO 0);
        ELSE
            phyaddr<=haddr(Physical_size-1 DOWNTO 0);
        END IF;
    END PROCESS;
    
    address_bram <= phyaddr; --New address to access the BRAM

END behavior;
