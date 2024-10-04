-- **************************************************************************************
--	Filename:	bram_controller.vhd
--	Project:	CNL_RISC-V
--  Version:	1.0
--	History:
--	Date:		3 April 2024
--
-- Copyright (C) 2024 CINI Cybersecurity National Laboratory
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
--	BRAM controller
--
-- **************************************************************************************
LIBRARY IEEE;
LIBRARY STD;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.NUMERIC_STD.ALL;


ENTITY bram_controller IS 
	PORT (
	    --system signals
		clk           : IN  STD_LOGIC;
		rst           : IN  STD_LOGIC;
		--input
		chip_select   : IN  STD_LOGIC;
		request       : IN  STD_LOGIC;
		--output
		memWrite      : OUT STD_LOGIC;
		memRead       : OUT STD_LOGIC;
		memResponse   : OUT STD_LOGIC;
		memReady      : OUT STD_LOGIC
	);
END bram_controller;

ARCHITECTURE behavior OF bram_controller IS

    TYPE statetype IS (IDLE, MEM_READ1, MEM_READ2, MEM_WRITE);
    SIGNAL next_state, current_state: statetype;
    SIGNAL readReq, writeReq: STD_LOGIC;

BEGIN

    PROCESS(clk,rst)
    BEGIN
        IF rst='1' THEN
            current_state<=IDLE;
        ELSIF rising_edge(clk) THEN
            current_state<=next_state;
        END IF;
    END PROCESS;
    
    readReq<=chip_select and (not request);
    writeReq<=chip_select and request;
    
    PROCESS(readReq, writeReq, current_state)
    BEGIN
        --memResponse is always 0 (no data integrity check or write protection mechanisms)
        memResponse<='0';
        memWrite<= '0';
        memRead <= '0';
        memReady <= '1'; --The memory can be accessed when it's not perfoming any operation
        next_state <= current_state;
        
        CASE current_state IS
        
            WHEN IDLE=>
                IF readReq= '1' THEN
                    next_state<=MEM_READ1;  
                    memRead <= '1';               
                    memReady <= '0';
                ELSIF writeReq='1' THEN
                    next_state <= MEM_WRITE;
                    memWrite <= '1';
                    memReady <= '0';
                ELSE 
                    next_state<=IDLE;
                END IF;

            WHEN MEM_READ1 => --This state is necessary because the BRAM has a delayed for writing of 2 cc
                memReady <= '0';
                next_state <= MEM_READ2;
            
            
            WHEN MEM_READ2 =>
                memReady <= '1';
                IF readReq = '1' THEN
                    next_state <= MEM_READ1;
                    memRead <= '1';
                ELSIF writeReq = '1' THEN
                    next_state <= MEM_WRITE;
                    memWrite <= '1';
                ELSE
                    next_state <= IDLE;
                    memRead <= '0';
                END IF;
                
            
            
            WHEN MEM_WRITE =>
                memReady <= '1';
                IF writeReq = '1' THEN
                    next_state <= MEM_WRITE;
                    memWrite <= '1';
                ELSIF readReq = '1' THEN
                    next_state <= MEM_READ1;
                    memRead <= '1';
                
                ELSE 
                    next_state <= IDLE;
                    memWrite <= '0';
                    
                 END IF;
                 
            
            WHEN OTHERS =>
                next_state <= IDLE;

            END CASE;
    END PROCESS;

END behavior;


