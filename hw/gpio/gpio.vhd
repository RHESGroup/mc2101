-- **************************************************************************************
--	Filename:	gpio.vhd
--	Project:	CNL_RISC-V
--	Version:	1.0
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
--	gpio peripheral top level
--
-- **************************************************************************************

LIBRARY IEEE;
LIBRARY STD;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.NUMERIC_STD.ALL;

ENTITY gpio IS   
	PORT (
	   --INPUTS
	    --system signals
		clk           : IN  STD_LOGIC;
		rst           : IN  STD_LOGIC;
		--input from bus wrapper
		address       : IN  STD_LOGIC_VECTOR(4 DOWNTO 0);
		busDataIn     : IN  STD_LOGIC_VECTOR(31 DOWNTO 0);
		read          : IN  STD_LOGIC;
		write         : IN  STD_LOGIC;
		--OUTPUTS
		--output to bus wrapper
		busDataOut    : OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
		interrupt     : OUT STD_LOGIC;
		--INOUTS
		--bidirectional channel from gpio pads
		gpio_pads     : INOUT STD_LOGIC_VECTOR(31 DOWNTO 0)
	);
END gpio;

ARCHITECTURE behavior OF gpio IS

    SIGNAL gpio_core_ins: STD_LOGIC_VECTOR(31 DOWNTO 0);
    SIGNAL gpio_core_outs: STD_LOGIC_VECTOR(31 DOWNTO 0);
    SIGNAL gpio_core_dirs: STD_LOGIC_VECTOR(31 DOWNTO 0);
    SIGNAL gpio_core_en: STD_LOGIC_VECTOR(31 DOWNTO 0);

BEGIN

    core: ENTITY work.gpio_core   
	PORT MAP(
		clk=>clk,
		rst=>rst,
		address=>address,
		busDataIn=>busDataIn,
		read=>read,
		write=>write,
		busDataOut=>busDataOut,
		interrupt=>interrupt,
	    gpio_in_async=>gpio_core_ins,
		gpio_out_sync=>gpio_core_outs,
		gpio_pad_dir=>gpio_core_dirs,
		gpio_en=>gpio_core_en
	);
    
    pads: ENTITY work.gpio_pads_if   
	PORT MAP(
	    gpio_pins=>gpio_pads,
	    gpio_port_in=>gpio_core_ins,
	    gpio_pad_dir=>gpio_core_dirs,
	    gpio_port_out=>gpio_core_outs,
	    gpio_en=>gpio_core_en
	);

END behavior;

