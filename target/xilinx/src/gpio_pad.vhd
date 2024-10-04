-- **************************************************************************************
--	Filename:	gpio_pads_if.vhd
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
--	gpio pads interface: interface to bidirectional bus connected to physical pins
--
-- **************************************************************************************
LIBRARY IEEE;
LIBRARY STD;
Library UNISIM;
USE UNISIM.VCOMPONENTS.ALL;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.NUMERIC_STD.ALL;

ENTITY gpio_pad IS   
	PORT (
	    --INPUTS
	    clk,rst    :   IN STD_LOGIC;
	    gpio_dir :     IN STD_LOGIC;
	    gpio_port_out: IN STD_LOGIC;
	    --OUTPUTS
	    gpio_port_in : OUT STD_LOGIC;
	    --INOUTS
	    gpio_pin:  INOUT STD_LOGIC
	);
END gpio_pad;

ARCHITECTURE struct OF gpio_pad IS

    SIGNAL gpio_enable: STD_LOGIC := '0';

BEGIN


    
    gpio_enable <= NOT(gpio_dir);
    

    IOBUF_inst : IOBUF
    generic map (
        DRIVE => 12,
        IOSTANDARD => "DEFAULT",
        SLEW => "FAST")
        port map (
        O =>  gpio_port_in, -- Buffer output
        IO => gpio_pin,   -- Buffer inout port (connect directly to top-level port)
        I => gpio_port_out,     -- Buffer input
        T => gpio_enable      -- 3-state enable input, high=output, low=input
    );
    
    


END struct;
