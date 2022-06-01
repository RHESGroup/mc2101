-- **************************************************************************************
--	Filename:	tb_gpio_pads_if.vhd
--	Project:	CNL_RISC-V
--  Version:	1.0
--	History:
--	Date:		27 May 2022
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
--	testbench for pads if
--
-- **************************************************************************************
LIBRARY IEEE;
LIBRARY STD;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.NUMERIC_STD.ALL;

ENTITY tb_gpio_pads_if IS
END tb_gpio_pads_if;

ARCHITECTURE tb OF tb_gpio_pads_if IS

    COMPONENT gpio_pads_if IS   
	PORT (
	    gpio_pins:  INOUT STD_LOGIC_VECTOR( 31 DOWNTO 0);
	    gpio_port_in : OUT STD_LOGIC_VECTOR( 31 DOWNTO 0);
	    gpio_pad_dir : IN STD_LOGIC_VECTOR( 31 DOWNTO 0);
	    gpio_port_out: IN STD_LOGIC_VECTOR( 31 DOWNTO 0)
	);
    END COMPONENT;
    
    SIGNAL gpio_pins: STD_LOGIC_VECTOR(31 DOWNTO 0);
    SIGNAL gpio_port_in: STD_LOGIC_VECTOR(31 DOWNTO 0);
    SIGNAL gpio_pad_dir: STD_LOGIC_VECTOR(31 DOWNTO 0);
    SIGNAL gpio_port_out: STD_LOGIC_VECTOR(31 DOWNTO 0);

BEGIN

    uut: gpio_pads_if  
	PORT MAP(
	    gpio_pins=>gpio_pins,
	    gpio_port_in=>gpio_port_in,
	    gpio_pad_dir=>gpio_pad_dir,
	    gpio_port_out=>gpio_port_out
	);

    PROCESS
    BEGIN
        --all inputs
        gpio_pad_dir<=(OTHERS=>'0');
        --should read all 0
        gpio_pins<=(OTHERS=>'0');
        --this outputs should be ignored
        gpio_port_out<=(OTHERS=>'1');
        WAIT FOR 10 ns;
        --all inputs
        gpio_pad_dir<=(OTHERS=>'0');
        --should read all 1
        gpio_pins<=(OTHERS=>'1');
        --this outputs should be ignored
        gpio_port_out<=(OTHERS=>'1');
        WAIT FOR 10 ns;
        --OUT-IN-OUT-IN
        gpio_pad_dir<=x"AAAAAAAA";
        --write on pins 1 and 3 (NO CONFLICT SHOULD HAPPEN)
        gpio_pins(0)<='1';
        gpio_pins(2)<='0';
        --pin 0 and 1 are written with 1
        gpio_port_out<=(OTHERS=>'1');
        --the overall situation of the gpio_pins should be: 1101
        WAIT;
    END PROCESS;
    
END tb;
