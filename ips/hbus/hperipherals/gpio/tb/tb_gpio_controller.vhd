-- **************************************************************************************
--	Filename:	tb_gpio_controller.vhd
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
--	gpio peripheral controller testbench
--
-- **************************************************************************************

LIBRARY IEEE;
LIBRARY STD;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.NUMERIC_STD.ALL;

ENTITY tb_gpio_controller IS   
END tb_gpio_controller;

ARCHITECTURE behavior OF tb_gpio_controller IS

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
	    gpio_ready  :OUT STD_LOGIC;
	    gpio_resp   :OUT STD_LOGIC
	);
    END COMPONENT;
    
    SIGNAL clk         :STD_LOGIC;
    SIGNAL rst         :STD_LOGIC;
    SIGNAL chip_select :STD_LOGIC;
	SIGNAL request     :STD_LOGIC;
	SIGNAL addr_base   :STD_LOGIC_VECTOR(1 DOWNTO 0);
	SIGNAL gpio_read   :STD_LOGIC;
	SIGNAL gpio_write  :STD_LOGIC;
	SIGNAL shiftDout   :STD_LOGIC;
	SIGNAL shiftDin    :STD_LOGIC;
	SIGNAL gpio_ready  :STD_LOGIC;
	SIGNAL gpio_resp   :STD_LOGIC;
	
	CONSTANT period: TIME:=20 ns;

BEGIN

    uut: gpio_controller   
	PORT MAP(
	    clk         =>clk,  
	    rst         =>rst,
	    chip_select =>chip_select,
		request     =>request,
	    addr_base   =>addr_base,
	    gpio_read   =>gpio_read,
	    gpio_write  =>gpio_write,
	    shiftDout   =>shiftDout,
	    shiftDin    =>shiftDin,
	    gpio_ready  =>gpio_ready,
	    gpio_resp   =>gpio_resp
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
	    WAIT FOR period;
	    rst<='0';
	    --4 byte read misaligned
	    chip_select<='1';
	    request<='0';
	    addr_base<="01";
	    WAIT FOR period;
	    chip_select<='1';
	    request<='0';
	    addr_base<="10";
	    WAIT FOR period;
	    chip_select<='1';
	    request<='0';
	    addr_base<="11";
	    WAIT FOR period;
	    chip_select<='1';
	    request<='0';
	    addr_base<="00";
	    WAIT FOR period;
	    --4 clock cycles of idle
	    chip_select<='0';
	    request<='0';
	    WAIT FOR period;
	    WAIT FOR period;
	    WAIT FOR period;
	    WAIT FOR period;
	    --2 byte read misaligned
	    chip_select<='1';
	    request<='0';
	    addr_base<="10";
	    WAIT FOR period;
	    chip_select<='1';
	    request<='0';
	    addr_base<="11";
	    WAIT FOR period;
	    --4 clock cycles of idle
	    chip_select<='0';
	    request<='0';
	    WAIT FOR period;
	    WAIT FOR period;
	    WAIT FOR period;
	    WAIT FOR period;
	    --1 byte read misaligned
	    chip_select<='1';
	    request<='0';
	    addr_base<="11";
	    WAIT FOR period;
	    --4 clock cycles of idle
	    chip_select<='0';
	    request<='0';
	    WAIT FOR period;
	    WAIT FOR period;
	    WAIT FOR period;
	    WAIT FOR period;
	    --4 byte read aligned
	    chip_select<='1';
	    request<='0';
	    addr_base<="00";
	    WAIT FOR period;
	    chip_select<='1';
	    request<='0';
	    addr_base<="01";
	    WAIT FOR period;
	    chip_select<='1';
	    request<='0';
	    addr_base<="10";
	    WAIT FOR period;
	    chip_select<='1';
	    request<='0';
	    addr_base<="11";
	    WAIT FOR period;
	    --1 clock cycles of idle
	    chip_select<='0';
	    request<='0';
	    WAIT FOR period;
	    --2 byte read aligned
	    chip_select<='1';
	    request<='0';
	    addr_base<="00";
	    WAIT FOR period;
	    chip_select<='1';
	    request<='0';
	    addr_base<="01";
	    WAIT FOR period;
	    --4 clock cycles of idle
	    chip_select<='0';
	    request<='0';
	    WAIT FOR period;
	    WAIT FOR period;
	    WAIT FOR period;
	    WAIT FOR period;
	    --4 byte write misaligned
	    chip_select<='1';
	    request<='1';
	    addr_base<="01";
	    WAIT FOR period;
	    chip_select<='1';
	    request<='1';
	    addr_base<="10";
	    WAIT FOR period;
	    chip_select<='1';
	    request<='1';
	    addr_base<="11";
	    WAIT FOR period;
	    chip_select<='1';
	    request<='1';
	    addr_base<="00";
	    WAIT FOR period;
	    --4 clock cycles of idle
	    chip_select<='0';
	    request<='0';
	    WAIT FOR period;
	    WAIT FOR period;
	    WAIT FOR period;
	    WAIT FOR period;
	    --4 byte write aligned
	    chip_select<='1';
	    request<='1';
	    addr_base<="00";
	    WAIT FOR period;
	    chip_select<='1';
	    request<='1';
	    addr_base<="01";
	    WAIT FOR period;
	    chip_select<='1';
	    request<='1';
	    addr_base<="10";
	    WAIT FOR period;
	    chip_select<='1';
	    request<='1';
	    addr_base<="11";
	    WAIT FOR period;
	    --idle
	    chip_select<='0';
	    request<='0';
	    WAIT;
	END PROCESS;

END behavior;













