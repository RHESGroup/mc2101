-- **************************************************************************************
--	Filename:	gpio_bus_wrap.vhd
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
--	gpio peripheral bus wrapper
--
-- **************************************************************************************

LIBRARY IEEE;
LIBRARY STD;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.NUMERIC_STD.ALL;


ENTITY gpio_bus_wrap IS
	GENERIC (
		busDataWidth      : INTEGER := 8;
		busAddressWidth   : INTEGER := 32
	);  
	PORT (
	    --INPUTS
	    --#BUS INTERFACE SIGNAL
	    --system signals
		clk           : IN  STD_LOGIC;
		rst           : IN  STD_LOGIC;
		--master driven signals
		htrans        : IN  STD_LOGIC_VECTOR(1 DOWNTO 0);
		hselx         : IN  STD_LOGIC;
		hwrite        : IN  STD_LOGIC;
		hwrdata       : IN  STD_LOGIC_VECTOR(busDataWidth-1 DOWNTO 0);
		haddr         : IN  STD_LOGIC_VECTOR(busAddressWidth-1 DOWNTO 0);
		--OUTPUTS
		--slave driven signals
		hrdata        : OUT STD_LOGIC_VECTOR(busDataWidth-1 DOWNTO 0);
		hready        : OUT STD_LOGIC;
		hresp         : OUT STD_LOGIC;
		--#EXTERNAL SIGNAL
	    gpio_interrupt: OUT STD_LOGIC;
	    --INOUTS
	    gpio_pads     : INOUT STD_LOGIC_VECTOR(31 DOWNTO 0)
	);
END gpio_bus_wrap;

ARCHITECTURE behavior OF gpio_bus_wrap IS     
    
    SIGNAL dataREAD  : STD_LOGIC_VECTOR(31 DOWNTO 0);
    SIGNAL dataWRITE : STD_LOGIC_VECTOR(31 DOWNTO 0);
    SIGNAL addrLATCH : STD_LOGIC_VECTOR(4 DOWNTO 0);
    SIGNAL gpio_out  : STD_LOGIC_VECTOR(31 DOWNTO 0);
    SIGNAL gpio_read : STD_LOGIC;
    SIGNAL gpio_write: STD_LOGIC;
    SIGNAL shiftDout : STD_LOGIC;
    SIGNAL shiftDin  : STD_LOGIC;
    SIGNAL latchAin  : STD_LOGIC;
    SIGNAL clear     : STD_LOGIC;
    
    SIGNAL addr      : STD_LOGIC_VECTOR(4 DOWNTO 0);
    SIGNAL phy_addr  : STD_LOGIC_VECTOR(4 DOWNTO 0);
    SIGNAL align_bits: STD_LOGIC_VECTOR(1 DOWNTO 0);
    

BEGIN

    PROCESS(clk, rst)
    BEGIN
        IF (rst='1')THEN
            dataREAD<=(OTHERS=>'0');
        ELSIF (rising_edge(clk)) THEN
            IF gpio_read = '1' THEN
                dataREAD<=gpio_out;
            ELSIF (shiftDout = '1') THEN  
                dataREAD(23 DOWNTO 16)<=dataREAD(31 DOWNTO 24);
                dataREAD(15 DOWNTO 8)<=dataREAD(23 DOWNTO 16);
                dataREAD(7 DOWNTO 0)<=dataREAD(15 DOWNTO 8);
            ELSIF (clear = '1') THEN
                dataREAD<=(OTHERS=>'0');
            END IF;
        END IF;
    END PROCESS;
    
    hrdata<=dataREAD(7 DOWNTO 0);
    
    PROCESS(clk, rst)
    BEGIN
        IF (rst='1')THEN
            dataWRITE<=(OTHERS=>'0');
        ELSIF (rising_edge(clk))THEN      
            IF (shiftDin = '1') THEN       
                dataWRITE(31 DOWNTO 24)<=hwrdata;
                dataWRITE(23 DOWNTO 16)<=dataWRITE(31 DOWNTO 24);
                dataWRITE(15 DOWNTO 8)<=dataWRITE(23 DOWNTO 16);
                dataWRITE(7 DOWNTO 0)<=dataWRITE(15 DOWNTO 8);
            ELSIF (clear = '1') THEN
                dataWRITE<=(OTHERS=>'0');
            END IF;
        END IF;
    END PROCESS;
    
    PROCESS(clk, rst)--, latchAin)
    BEGIN
        IF rst='1' THEN
            addrLATCH<=(OTHERS=>'0');
        ELSIF (rising_edge(clk)) THEN
            IF (latchAin='1') THEN
                addrLATCH<=phy_addr;
            END IF;
        END IF;
    END PROCESS;
    
    phy_addr<=haddr(4 DOWNTO 0);
    align_bits<=haddr(1 DOWNTO 0);
    
    addr<=addrLATCH WHEN gpio_write='1' ELSE
          phy_addr;
    
    periph_gpio: ENTITY work.gpio  
	PORT MAP(
		clk           =>clk,
		rst           =>rst,
		address       =>addr,
		busDataIn     =>dataWRITE,
		read          =>gpio_read,
		write         =>gpio_write,
		busDataOut    =>gpio_out,
		interrupt     =>gpio_interrupt,
		gpio_pads     =>gpio_pads
	);
	
	controller: ENTITY work.gpio_controller 
	PORT MAP(
	    clk         =>clk,
	    rst         =>rst,
	    chip_select =>hselx,
		request     =>hwrite,
	    addr_base   =>align_bits,
	    gpio_read   =>gpio_read,
	    gpio_write  =>gpio_write,
	    shiftDout   =>shiftDout,
	    shiftDin    =>shiftDin,
	    latchAin    =>latchAin,
	    gpio_ready  =>hready,
	    clear       =>clear,
	    gpio_resp   =>hresp
	);

END behavior;









