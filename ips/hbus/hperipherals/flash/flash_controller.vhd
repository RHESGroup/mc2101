-- **************************************************************************************
--	Filename:	flash_controller.vhd
--	Project:	CNL_RISC-V
--  Version:	1.0
--	History:
--	Date:		10 May 2022
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
--	flash hbus peripheral controller
--
-- **************************************************************************************
LIBRARY IEEE;
LIBRARY STD;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.NUMERIC_STD.ALL;


ENTITY flash_controller IS 
	PORT (
	    --system signals
		clk           : IN  STD_LOGIC;
		rst           : IN  STD_LOGIC;
		--input
		chip_select   : IN  STD_LOGIC;
		--request       : IN  STD_LOGIC;
		--output
		readEnable    : OUT STD_LOGIC;
		--memWrite      : OUT STD_LOGIC;
		memResponse   : OUT STD_LOGIC;
		memReady      : OUT STD_LOGIC
	);
END flash_controller;

ARCHITECTURE behavior OF flash_controller IS

    TYPE statetype IS (IDLE, MEM_RD);
    SIGNAL next_state, current_state: statetype;

BEGIN

    PROCESS(clk,rst)
    BEGIN
        IF rst='1' THEN
            current_state<=IDLE;
        ELSIF rising_edge(clk) THEN
            current_state<=next_state;
        END IF;
    END PROCESS;
    
    PROCESS(chip_select, current_state)
    BEGIN
        --no stall cycles are inserted
        --memReady is always 1
        --timing should be checked with gate level simulation
        memReady<='1';
        memResponse<='1';
        CASE current_state IS
            WHEN IDLE=>
                IF chip_select= '1' THEN
                    next_state<=MEM_RD;
                    readEnable<='1';
                ELSE
                    next_state<=IDLE;
                    readEnable<='0';
                END IF;
            WHEN MEM_RD=>
                next_state<=IDLE;
                readEnable<='0';
        END CASE;
    END PROCESS;

END behavior;

--should the controller check for a write attempt?
