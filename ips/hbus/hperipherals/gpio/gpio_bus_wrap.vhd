-- **************************************************************************************
--	Filename:	gpio_bus_wrap.vhd
--	Project:	CNL_RISC-V
--  Version:	1.0
--	History:
--	Date:		01 Jun 2022
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
		--slave driven signals
		hrdata        : OUT STD_LOGIC_VECTOR(busDataWidth-1 DOWNTO 0);
		hready        : OUT STD_LOGIC;
		hresp         : OUT STD_LOGIC;
		--#EXTERNAL SIGNAL
	    gpio_interrupt: OUT STD_LOGIC;
	    gpio_pads     : INOUT STD_LOGIC_VECTOR(31 DOWNTO 0)
	);
END gpio_bus_wrap;

ARCHITECTURE behavior OF gpio_bus_wrap IS

    COMPONENT gpio IS   
	PORT (
	    --system signals
		clk           : IN  STD_LOGIC;
		rst           : IN  STD_LOGIC;
		--input from bus wrapper
		address       : IN  STD_LOGIC_VECTOR(4 DOWNTO 0);
		busDataIn     : IN  STD_LOGIC_VECTOR(31 DOWNTO 0);
		read          : IN  STD_LOGIC;
		write         : IN  STD_LOGIC;
		--output to bus wrapper
		busDataOut    : OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
		interrupt     : OUT STD_LOGIC;
		--bidirectional channel from gpio pads
		gpio_pads     : INOUT STD_LOGIC_VECTOR(31 DOWNTO 0)
	);
    END COMPONENT;
    
    SIGNAL dataREAD  : STD_LOGIC_VECTOR(31 DOWNTO 0);
    SIGNAL dataWRITE : STD_LOGIC_VECTOR(31 DOWNTO 0);
    SIGNAL addrLATCH : STD_LOGIC_VECTOR(4 DOWNTO 0);
    SIGNAL gpio_out  : STD_LOGIC_VECTOR(31 DOWNTO 0);
    SIGNAL gpio_read : STD_LOGIC;
    SIGNAL gpio_write: STD_LOGIC;
    SIGNAL shiftDout : STD_LOGIC;
    SIGNAL shiftDin  : STD_LOGIC;
    SIGNAL latchAin  : STD_LOGIC;
    
    SIGNAL phy_addr  : STD_LOGIC_VECTOR(4 DOWNTO 0);
    SIGNAL align_bits: STD_LOGIC_VECTOR(1 DOWNTO 0);
    
    COMPONENT gpio_controller IS   
	PORT (
	    clk         :IN STD_LOGIC;
	    rst         :IN STD_LOGIC;
	    chip_select :IN  STD_LOGIC;
		request     :IN  STD_LOGIC;
	    addr_base   :IN STD_LOGIC_VECTOR(1 DOWNTO 0);
	    gpio_read   :OUT STD_LOGIC;
	    gpio_write  :OUT STD_LOGIC;
	    shiftDout   :OUT STD_LOGIC;
	    shiftDin    :OUT STD_LOGIC;
	    latchAin    :OUT STD_LOGIC;
	    gpio_ready  :OUT STD_LOGIC;
	    gpio_resp   :OUT STD_LOGIC
	);
    END COMPONENT;

BEGIN

    PROCESS(clk, rst)
    BEGIN
        IF rst='1' THEN
            dataREAD<=(OTHERS=>'0');
        ELSIF rising_edge(clk) THEN
            IF gpio_read = '1' THEN
                dataREAD<=gpio_out;
            ELSIF shiftDout = '1' THEN
                dataREAD(31 DOWNTO 24)<=dataREAD(23 DOWNTO 16);
                dataREAD(23 DOWNTO 16)<=dataREAD(15 DOWNTO 8);
                dataREAD(15 DOWNTO 8)<=dataREAD(7 DOWNTO 0);
            END IF;
        END IF;
    END PROCESS;
    
    PROCESS(clk, rst)
    BEGIN
        IF rst='1' THEN
            dataWRITE<=(OTHERS=>'0');
        ELSIF ( rising_edge(clk) AND shiftDin='1' )THEN        
            dataWRITE(31 DOWNTO 24)<=hwrdata;
            dataWRITE(23 DOWNTO 16)<=dataWRITE(31 DOWNTO 24);
            dataWRITE(15 DOWNTO 8)<=dataWRITE(23 DOWNTO 16);
            dataWRITE(7 DOWNTO 0)<=dataWRITE(15 DOWNTO 8);
        END IF;
    END PROCESS;
    
    PROCESS(clk, rst)
    BEGIN
        IF rst='1' THEN
            addrLATCH<=(OTHERS=>'0');
        ELSIF rising_edge(clk) AND latchAin='1' THEN
            addrLATCH<=phy_addr;
        END IF;
    
    END PROCESS;
    
    phy_addr<=haddr(4 DOWNTO 0);
    align_bits<=haddr(1 DOWNTO 0);
    
    periph_gpio: gpio  
	PORT MAP(
		clk           =>clk,
		rst           =>rst,
		address       =>addrLATCH,
		busDataIn     =>dataWRITE,
		read          =>gpio_read,
		write         =>gpio_write,
		busDataOut    =>gpio_out,
		interrupt     =>gpio_interrupt,
		gpio_pads     =>gpio_pads
	);
	
	controller: gpio_controller 
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
	    gpio_ready  =>hready,
	    gpio_resp   =>hresp
	);

END behavior;









