-- **************************************************************************************
--	Filename:	hsystem.vhd
--	Project:	CNL_RISC-V
--  Version:	1.0
--	History:
--	Date:		18 May 2022
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
--	CNL_RISC-V microcontroller hbus
--
-- **************************************************************************************
LIBRARY IEEE;
LIBRARY STD;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.NUMERIC_STD.ALL;

ENTITY hsystem IS
	PORT(
	    sys_clk: IN  STD_LOGIC;
	    sys_rst: IN  STD_LOGIC
	);
END hsystem;


ARCHITECTURE behavior OF hsystem IS

    --BUS CONFIGURATION
    CONSTANT busDataWidth: INTEGER:=8;
    CONSTANT busAddressWidth: INTEGER:=32;

    --MASTER INTERFACE
    COMPONENT bus_master_if IS
    GENERIC (
		busDataWidth      : INTEGER := 8;
		busAddressWidth   : INTEGER := 32
	); 
	PORT (
	    --system signals
		clk           : IN  STD_LOGIC;
		rst           : IN  STD_LOGIC;
		--input
		hready        : IN  STD_LOGIC;
		hresp         : IN  STD_LOGIC;
		hrdata        : IN  STD_LOGIC_VECTOR(busDataWidth-1 DOWNTO 0);
		--output
		haddr         : OUT STD_LOGIC_VECTOR(busAddressWidth-1 DOWNTO 0);
		hwrdata       : OUT STD_LOGIC_VECTOR(busDataWidth-1 DOWNTO 0);
		hwrite        : OUT STD_LOGIC;
		htrans        : OUT STD_LOGIC_VECTOR(1 DOWNTO 0);
		--slave select (size must be extended to the number of slaves)
		hselram       : OUT STD_LOGIC;
		hselflash     : OUT STD_LOGIC;
		hselgpio      : OUT STD_LOGIC;
		hseluart      : OUT STD_LOGIC
		);
    END COMPONENT;
    
    --SLAVES INTERFACE
    COMPONENT ssram_bus_wrap IS
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
    END COMPONENT;
    
    SIGNAL ssram_hrdata: STD_LOGIC_VECTOR(busDataWidth-1 DOWNTO 0);
    SIGNAL ssram_hready: STD_LOGIC;
    SIGNAL ssram_hresp:  STD_LOGIC;
    
    COMPONENT flash_bus_wrap IS
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
    END COMPONENT;
    
    
    
    SIGNAL flash_hrdata: STD_LOGIC_VECTOR(busDataWidth-1 DOWNTO 0);
    SIGNAL flash_hready: STD_LOGIC;
    SIGNAL flash_hresp:  STD_LOGIC;
    
    --BUS INTERCONNECTION
    SIGNAL htrans: STD_LOGIC_VECTOR(1 DOWNTO 0);
    SIGNAL hselram: STD_LOGIC;
    SIGNAL hselflash: STD_LOGIC;
    SIGNAL hselgpio: STD_LOGIC;
    SIGNAL hseluart: STD_LOGIC;
    SIGNAL hwrite: STD_LOGIC;
    SIGNAL hwrdata: STD_LOGIC_VECTOR(busDataWidth-1 DOWNTO 0);
    SIGNAL haddr: STD_LOGIC_VECTOR(busAddressWidth-1 DOWNTO 0);
    SIGNAL hrdata: STD_LOGIC_VECTOR(busDataWidth-1 DOWNTO 0);
    SIGNAL hresp: STD_LOGIC;
    SIGNAL hready: STD_LOGIC;
    
    
BEGIN

    master: bus_master_if
    GENERIC MAP(
		busDataWidth=>busDataWidth,
		busAddressWidth=>busAddressWidth
	) 
	PORT MAP(
		clk=>sys_clk,
		rst=>sys_rst,
		hready=>hready,
		hresp=>hresp,
		hrdata=>hrdata,
		haddr=>haddr,
		hwrdata=>hwrdata,
		hwrite=>hwrite,
		htrans=>htrans,
		hselram=>hselram,
		hselflash=>hselflash,
		hselgpio=>hselgpio,
		hseluart=>hseluart
    );
    
    slave_ram: ssram_bus_wrap
	GENERIC MAP(
		busDataWidth=>busDataWidth,
		busAddressWidth=>busAddressWidth
	)  
	PORT MAP(
		clk=>sys_clk,
		rst=>sys_rst,
		htrans=>htrans,
		hselx=>hselram,
		hwrite=>hwrite,
		hwrdata=>hwrdata,
		haddr=>haddr,
		hrdata=>ssram_hrdata,
		hready=>ssram_hready,
		hresp=>ssram_hresp
	);
	
	slave_flash: flash_bus_wrap
	GENERIC MAP(
		busDataWidth=>busDataWidth,
		busAddressWidth=>busAddressWidth
	)  
	PORT MAP(
		clk=>sys_clk,
		rst=>sys_rst,
		htrans=>htrans,
		hselx=>hselflash,
		hwrite=>hwrite,
		hwrdata=>hwrdata,
		haddr=>haddr,
		hrdata=>flash_hrdata,
		hready=>flash_hready,
		hresp=>flash_hresp
	);
	
	--SLAVES MUX
	hrdata<=flash_hrdata WHEN hselflash = '1' ELSE
	        ssram_hrdata;
	        
	hready<=flash_hready WHEN hselflash = '1' ELSE
	        ssram_hready;
	        
	hresp <=flash_hresp  WHEN hselflash = '1' ELSE
	        ssram_hresp;

END behavior;
