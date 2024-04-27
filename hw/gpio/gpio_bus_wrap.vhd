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
		htrans        : IN  STD_LOGIC_VECTOR(1 DOWNTO 0); --Shows the current state of the bus
		hselx         : IN  STD_LOGIC; --CHIP SELECT signal -- Enables the peripheral selection
		hwrite        : IN  STD_LOGIC; --Indicates the transfer direction. Write(1) or Read(0)
		hwrdata       : IN  STD_LOGIC_VECTOR(busDataWidth-1 DOWNTO 0); --Data lines from mater to slave. It comes from the AFTAB
		haddr         : IN  STD_LOGIC_VECTOR(busAddressWidth-1 DOWNTO 0); --Address
		--OUTPUTS
		--slave driven signals
		hrdata        : OUT STD_LOGIC_VECTOR(busDataWidth-1 DOWNTO 0); --Data lines from slave to master. It goes to the AFTAB
		hready        : OUT STD_LOGIC; --When driven low, the transfer is extended
		hresp         : OUT STD_LOGIC; --When high, indicates that the transfer status is on error. It goes to the AFTAB
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

    periph_gpio: ENTITY work.gpio  
	PORT MAP(
	   --INPUTS
		clk           =>clk,
		rst           =>rst,
		address       =>addr,
		busDataIn     =>dataWRITE,
		read          =>gpio_read,
		write         =>gpio_write,
		--OUTPUTS
		busDataOut    =>gpio_out,
		interrupt     =>gpio_interrupt,
		--INOUTS
		gpio_pads     =>gpio_pads
	);
	
	controller: ENTITY work.gpio_controller 
	PORT MAP(
	   --INPUTS
	    clk         =>clk,
	    rst         =>rst,
	    chip_select =>hselx,
		request     =>hwrite,
	    addr_base   =>align_bits,
	    --OUTPUTS
	    gpio_read   =>gpio_read,
	    gpio_write  =>gpio_write,
	    shiftDout   =>shiftDout,
	    shiftDin    =>shiftDin,
	    latchAin    =>latchAin,
	    gpio_ready  =>hready,
	    clear       =>clear,
	    gpio_resp   =>hresp
	);
	--haddr has a size of 32 bits. However, we do not have to have this number of bits for the GPIO addressing
	phy_addr<=haddr(4 DOWNTO 0); --5 bit address signal that selects which user regiser is accessed by the AFTAB processor
    align_bits<=haddr(1 DOWNTO 0); --Signal that helps to check if the incoming address is aligned
    
    addr<=addrLATCH WHEN gpio_write='1' ELSE
          phy_addr; --Normally, we consider phy_addr(address of User Register)
    

    --Process associated with READING user register
    PROCESS(clk, rst)
    BEGIN
        IF (rst='1')THEN
            dataREAD<=(OTHERS=>'0');
        ELSIF (rising_edge(clk)) THEN
            IF gpio_read = '1' THEN --If the operation requested is a READ(set by the GPIO controller). We get this value when making the transition to READ state
                dataREAD<=gpio_out; --We read the 32 bits coming from the user register, but we have to shifth them out later.
            ELSIF (shiftDout = '1') THEN  --We shift 8 bits at at a time---When the CU is in READ state
                dataREAD(23 DOWNTO 16)<=dataREAD(31 DOWNTO 24);
                dataREAD(15 DOWNTO 8)<=dataREAD(23 DOWNTO 16);
                dataREAD(7 DOWNTO 0)<=dataREAD(15 DOWNTO 8);
            ELSIF (clear = '1') THEN --Before going back to IDLE state, we clear the register
                dataREAD<=(OTHERS=>'0');
            END IF;
        END IF;
    END PROCESS;
    
    hrdata<=dataREAD(7 DOWNTO 0); --Signal that goes to the AFTAB. We need four clock cycles to send the whole data(32 bits) to the AFTAB
    
    
    --Process associated with WRITING user registers. In particular, with the shifting of values
    PROCESS(clk, rst)
    BEGIN
        IF (rst='1')THEN
            dataWRITE<=(OTHERS=>'0');
        ELSIF (rising_edge(clk))THEN      
            IF (shiftDin = '1') THEN --We shift 8 bits at at a time---When the CU is in WRITE state
                dataWRITE(31 DOWNTO 24)<=hwrdata;
                dataWRITE(23 DOWNTO 16)<=dataWRITE(31 DOWNTO 24);
                dataWRITE(15 DOWNTO 8)<=dataWRITE(23 DOWNTO 16);
                dataWRITE(7 DOWNTO 0)<=dataWRITE(15 DOWNTO 8); --This is the signal that goes as input to the CORE
            ELSIF (clear = '1') THEN
                dataWRITE<=(OTHERS=>'0');
            END IF;
        END IF;
    END PROCESS;
    
    
    --Process associated with WRITING user registers. In particular, with the  preparation of the shifting to write valus into the user register
    PROCESS(clk, rst)--, latchAin)
    BEGIN
        IF rst='1' THEN
            addrLATCH<=(OTHERS=>'0');
        ELSIF (rising_edge(clk)) THEN
            IF (latchAin='1') THEN 
                addrLATCH<=phy_addr; --Signal that captures the address value of the register to be written
            END IF;
        END IF;
    END PROCESS;
    
END behavior;









