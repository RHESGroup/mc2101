-- **************************************************************************************
--	Filename:	tb_gpio_core.vhd
--	Project:	CNL_RISC-V
--  Version:	1.0
--	History:
--	Date:		25 May 2022
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
--	testbench for gpio peripheral core
--  LAST TESTED VERSION: 00010000
-- **************************************************************************************
LIBRARY IEEE;
LIBRARY STD;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.NUMERIC_STD.ALL;

ENTITY tb_gpio_core IS   
END tb_gpio_core;

ARCHITECTURE tb OF tb_gpio_core IS
    
    COMPONENT gpio_core IS   
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
		--input from gpio pad interface
	    gpio_in_async  : IN  STD_LOGIC_VECTOR(31 DOWNTO 0);
		--output to gpio pad interface
		gpio_out_sync : OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
		gpio_pad_dir  : OUT STD_LOGIC_VECTOR(31 DOWNTO 0)
	);
    END COMPONENT;
    
    SIGNAL clk : STD_LOGIC;
    SIGNAL rst : STD_LOGIC;
    SIGNAL address : STD_LOGIC_VECTOR(4 DOWNTO 0);
    SIGNAL busDataIn : STD_LOGIC_VECTOR(31 DOWNTO 0);
    SIGNAL read : STD_LOGIC;
    SIGNAL write : STD_LOGIC;
    SIGNAL busDataOut : STD_LOGIC_VECTOR(31 DOWNTO 0);
    SIGNAL interrupt : STD_LOGIC;
    SIGNAL gpio_in_async : STD_LOGIC_VECTOR(31 DOWNTO 0);
    SIGNAL gpio_out_sync : STD_LOGIC_VECTOR(31 DOWNTO 0);
    SIGNAL gpio_pad_dir : STD_LOGIC_VECTOR(31 DOWNTO 0);
    CONSTANT period: TIME:=20 ns;
        
BEGIN

    uut: gpio_core   
	PORT MAP(
		clk           =>clk,
		rst           =>rst,
		address       =>address,
		busDataIn     =>busDataIn,
		read          =>read,
		write         =>write,
		busDataOut    =>busDataOut,
		interrupt     =>interrupt,
	    gpio_in_async =>gpio_in_async,
		gpio_out_sync =>gpio_out_sync,
		gpio_pad_dir  =>gpio_pad_dir
	);

    
END tb;


