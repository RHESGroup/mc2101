-- **************************************************************************************
--	Filename:	tb_hsystem.vhd
--	Project:	CNL_RISC-V
--  Version:	1.0
--	History:
--	Date:		06 May 2022
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
--	Testbench for the CNL_RISC-V microcontroller hbus
--
-- **************************************************************************************
LIBRARY ieee;
USE ieee.std_logic_1164.ALL;

ENTITY tb_hsystem IS
END tb_hsystem;

ARCHITECTURE tb OF tb_hsystem IS

    COMPONENT hsystem IS
	PORT(
	    sys_clk: IN  STD_LOGIC;
	    sys_rst: IN  STD_LOGIC
	);
    END COMPONENT;

	CONSTANT clk_period : TIME := 30 ns;
	SIGNAL clk, rst: STD_LOGIC;

BEGIN

    system: hsystem
	PORT MAP(
	    sys_clk=>clk,
	    sys_rst=>rst
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
		-- hold reset state for 100 ns.
		WAIT FOR 120 ns;
		rst <= '1';
		WAIT FOR 40 ns;
		rst <= '0';
		WAIT;
	END PROCESS;

END tb;
