-- **************************************************************************************
--	Filename:	tb_mc2101.vhd
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
--	Testbench for the CNL_RISC-V microcontroller hbus
--
-- **************************************************************************************
LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
use work.Constants.ALL;

ENTITY tb_mc2101 IS
END tb_mc2101;

ARCHITECTURE tb OF tb_mc2101 IS

    COMPONENT mc2101_wrapper IS
	PORT(
        gpio_pads_0 : inout STD_LOGIC_VECTOR ( 31 downto 0 );
        reset_rtl : in STD_LOGIC;
        sys_clock : in STD_LOGIC;
        uart_rx_0 : in STD_LOGIC;
        uart_tx_0 : out STD_LOGIC
	);
    END COMPONENT;
    

	CONSTANT clk_period : TIME := 10 ns;
	SIGNAL gpio_pads_0_s:  STD_LOGIC_VECTOR(31 DOWNTO 0);
	SIGNAL clk, rst_rtl_s: STD_LOGIC;
	SIGNAL uart_rx_0_s,uart_tx_0_s: STD_LOGIC;
	

BEGIN

    microcontroller: mc2101_wrapper
	PORT MAP(
        gpio_pads_0 => gpio_pads_0_s,
        reset_rtl => rst_rtl_s,
        sys_clock => clk,
        uart_rx_0 => uart_rx_0_s,
        uart_tx_0 => uart_tx_0_s
	);

	clk_process : PROCESS
	BEGIN
		clk <= '0';
		WAIT FOR clk_period/2;
		clk <= '1';
		WAIT FOR clk_period/2;
	END PROCESS;
			
	-- Stimulus process
	stim_proc : PROCESS
	BEGIN		
		rst_rtl_s <= '1';
		WAIT FOR 120 ns;
		rst_rtl_s <= '0';
		WAIT;
	END PROCESS;

END tb;
