-- **************************************************************************************
--	Filename:	ssram_bus_wrap.vhd
--	Project:	CNL_RISC-V
--  Version:	1.0
--	History:
--	Date:		10 May 2022
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
--	ssram hbus peripheral wrapper
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
    COMPONENT ssram_fpga IS
	GENERIC (
		dataWidth      : INTEGER :=8;
		addressWidth   : INTEGER :=13
	);  
	PORT (
		clk           : IN  STD_LOGIC;
		readMem       : IN  STD_LOGIC;
		writeMem      : IN  STD_LOGIC;
		address       : IN  STD_LOGIC_VECTOR (addressWidth - 1 DOWNTO 0);
		dataIn     	  : IN  STD_LOGIC_VECTOR (dataWidth -1 DOWNTO 0);
		dataOut       : OUT STD_LOGIC_VECTOR (dataWidth -1 DOWNTO 0)
	);
    END COMPONENT;
    
    SIGNAL readMem: STD_LOGIC;
    SIGNAL writeMem: STD_LOGIC;
    SIGNAL dataOut: STD_LOGIC_VECTOR (busDataWidth -1 DOWNTO 0);
    SIGNAL ready: STD_LOGIC;
    --The actual physical size of the ram is 2**13
    CONSTANT PHSIZE: integer:=13;
    SIGNAL phyaddr: STD_LOGIC_VECTOR(PHSIZE-1 DOWNTO 0);
    
    --controller
    COMPONENT ssram_controller IS 
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

    memory: ssram_fpga
	GENERIC MAP(
		dataWidth      => busDataWidth,
		addressWidth   => PHSIZE
	)  
	PORT MAP(
		clk            =>clk,
		readMem        =>readMem,
		writeMem       =>writeMem,
		address        =>phyaddr,
		dataIn     	   =>hwrdata,
		dataOut        =>dataOut		   
	);
    
    controller: ssram_controller 
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
    --When haddr changes, in this module can assume two intervals:
    --1) haddr<=0x00001000 :Instruction Memory--->phaddr=haddr
    --2) haddr>=0x00100000 :Data OR Stack
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
