-- **************************************************************************************
--	Filename:	tb_gpio_core.vhd
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
		clk           : IN  STD_LOGIC;
		rst           : IN  STD_LOGIC;
		address       : IN  STD_LOGIC_VECTOR(4 DOWNTO 0);
		busDataIn     : IN  STD_LOGIC_VECTOR(31 DOWNTO 0);
		read          : IN  STD_LOGIC;
		write         : IN  STD_LOGIC;
		busDataOut    : OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
		interrupt     : OUT STD_LOGIC;
	    gpio_in_async : IN  STD_LOGIC_VECTOR(31 DOWNTO 0);
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
	
	PROCESS
	BEGIN
	    clk<='0';
	    WAIT FOR period/2;
	    clk<='1';
	    WAIT FOR period/2;
	END PROCESS;
	
	PROCESS
	BEGIN
	    rst<='1';
	    WAIT FOR period*5;
	    rst<='0';
	    WAIT FOR 5 ns;
	    read<='0';
	    write<='0';
	    address<=(OTHERS=>'0');
	    busDataIn<=(OTHERS=>'0');
	    WAIT FOR period*5;
	    --SET GPIO: 0,1,2,30,31 AS INPUTS, OTHERS AS OUTPUTS
	    --  SET PADDIR=0011 1111 1111 1111 1111 1111 1111 1000
	    write<='1';
	    address<=(OTHERS=>'0');
	    busDataIn<="10111111111111111111111111111000";
	    WAIT FOR period*2;
	    write<='0';
	    WAIT FOR period*2;
	    --SET INPUT PINS INTERRUPTS
	    --  DISABLE INTERRUPT(0)
	    --  ENABLE INTERRUPT 1  ON LEVEL 0
	    --  ENABLE INTERRUPT 2  ON LEVEL 1
	    --  ENABLE INTERRUPT 30 ON RISING
	    --  ENABLE INTERRUPT 31 ON FALLING
	    --  DISABLE ALL OTHERS
	    --      INTEN    = 1100 0000 0000 0000 0000 0000 0000 0110
	    --      INTTYPE0 = 1000 0000 0000 0000 0000 0000 0000 0010
	    --      INTTYPE1 = 1100 0000 0000 0000 0000 0000 0000 0000
	    write<='1';
	    address<="01100";
	    busDataIn<="11000000000000000000000000000110";
	    WAIT FOR period*2;
	    write<='0';
	    WAIT FOR period*2;
	    write<='1';
	    address<="10000";
	    busDataIn<="10000000000000000000000000000010";
	    WAIT FOR period*2;
	    write<='0';
	    WAIT FOR period*2;
	    write<='1';
	    address<="10100";
	    busDataIn<="11000000000000000000000000000000";
	    WAIT FOR period*2;
	    write<='0';
	    WAIT FOR period*10;
	    --READ PADDIR
	    --READ INTEN
	    --READ INTTYPE0
	    --READ INTTYPE1
	    read<='1';
	    address<=(OTHERS=>'0');
	    WAIT FOR period *2;
	    read<='0';
	    WAIT FOR period*2;
	    read<='1';
	    address<="01100";
	    WAIT FOR period *2;
	    read<='0';
	    WAIT FOR period*2;
	    read<='1';
	    address<="10000";
	    WAIT FOR period *2;
	    read<='0';
	    WAIT FOR period*2;
	    read<='1';
	    address<="10100";
	    WAIT FOR period *2;
	    read<='0';
	    WAIT FOR period*2;
	    --KEEP MONITORING INSTATUS WITH A PERIOD OF 1000 ns
	    address<="11000";
	    read<='1';
	    WAIT FOR 100 ns;
	    read<='0';
	    WAIT FOR 900 ns;
	    read<='1';
	    WAIT FOR 100 ns;
	    read<='0';
	    WAIT FOR 900 ns;
	    read<='1';
	    WAIT FOR 100 ns;
	    read<='0';
	    WAIT FOR 900 ns;
	    read<='1';
	    WAIT FOR 100 ns;
	    read<='0';
	    WAIT FOR 900 ns;
	    read<='1';
	    WAIT FOR 100 ns;
	    read<='0';
	    WAIT FOR 900 ns;
	    read<='1';
	    WAIT FOR 100 ns;
	    read<='0';
	    WAIT FOR 900 ns;
	    read<='1';
	    WAIT FOR 100 ns;
	    read<='0';
	    WAIT FOR 900 ns;
	    read<='1';
	    WAIT FOR 100 ns;
	    read<='0';
	    WAIT FOR 900 ns;
	    read<='1';
	    WAIT FOR 100 ns;
	    read<='0';
	    WAIT FOR 900 ns;
	    read<='1';
	    WAIT FOR 100 ns;
	    read<='0';
	    WAIT FOR 900 ns;
	    WAIT;
	END PROCESS;
	
	PROCESS
	BEGIN
	    gpio_in_async(0)<='0';
	    gpio_in_async(1)<='0';
	    gpio_in_async(2)<='0';    
	    WAIT FOR 1700 ns;
	    gpio_in_async(0)<='1';
	    gpio_in_async(1)<='0';
	    gpio_in_async(2)<='0';    
	    WAIT FOR 1700 ns;
	    gpio_in_async(0)<='0';
	    gpio_in_async(1)<='1';
	    gpio_in_async(2)<='0';   
	    WAIT FOR 1700 ns;
	    gpio_in_async(0)<='0';
	    gpio_in_async(1)<='0';
	    gpio_in_async(2)<='1';    
	    WAIT FOR 1700 ns;
	    gpio_in_async(0)<='0';
	    gpio_in_async(1)<='0';
	    gpio_in_async(2)<='0';   
	    WAIT FOR 1700 ns;
	    gpio_in_async(0)<='0';
	    gpio_in_async(1)<='0';
	    gpio_in_async(2)<='0';    
	    WAIT FOR 1700 ns;
	    gpio_in_async(0)<='1';
	    gpio_in_async(1)<='1';
	    gpio_in_async(2)<='1';    
	    WAIT FOR 1700 ns;
    END PROCESS;
    
    gpio_in_async(29 DOWNTO 3)<=(OTHERS=>'0');
    
    PROCESS
    BEGIN
        gpio_in_async(30)<='0';
	    gpio_in_async(31)<='0';
	    WAIT FOR period;
	    gpio_in_async(30)<='1';
	    gpio_in_async(31)<='1';
	    WAIT FOR period;
    END PROCESS;
    
END tb;


