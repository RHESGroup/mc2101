-- **************************************************************************************
--	Filename:	ssram_controller.vhd
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
--	ssram hbus peripheral controller
--
-- **************************************************************************************
LIBRARY IEEE;
LIBRARY STD;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.NUMERIC_STD.ALL;


ENTITY ssram_controller IS 
	PORT (
	    --system signals
		clk           : IN  STD_LOGIC;
		rst           : IN  STD_LOGIC;
		--input
		chip_select   : IN  STD_LOGIC;
		request       : IN  STD_LOGIC;
		--output
		memRead       : OUT STD_LOGIC;
		memWrite      : OUT STD_LOGIC;
		memSelByte    : OUT STD_LOGIC_VECTOR(1 DOWNTO 0);
		memResponse   : OUT STD_LOGIC;
		latchDinEn    : OUT STD_LOGIC;
		latchAinEn    : OUT STD_LOGIC;
		memReady      : OUT STD_LOGIC
	);
END ssram_controller;

ARCHITECTURE behavior OF ssram_controller IS

    TYPE statetype IS (IDLE, LATCH32, SERIAL_OUT, WR_BUFFER, MEM_WR);
    SIGNAL next_state, current_state: statetype;
    SIGNAL next_count, current_count: STD_LOGIC_VECTOR(1 DOWNTO 0);
    SIGNAL readReq, writeReq: STD_LOGIC;

BEGIN

    PROCESS(clk,rst)
    BEGIN
        IF rst='1' THEN
            current_state<=IDLE;
            current_count<=(OTHERS=>'0');
        ELSIF rising_edge(clk) THEN
            current_state<=next_state;
            current_count<=next_count;
        END IF;
    END PROCESS;
    
    readReq<=chip_select and (not request);
    writeReq<=chip_select and request;
    
    PROCESS(readReq, writeReq, current_state, current_count)
    BEGIN
        CASE current_state IS
            WHEN IDLE=>
                latchDinEn<='0';
                latchAinEn<='0';
                memResponse<='1';
                memRead<='0';
                memWrite<='0';
                memSelByte<=(OTHERS=>'0');
                next_count<=(OTHERS=>'0');
                IF readReq= '1' THEN
                    next_state<=LATCH32;
                    memRead<='1';
                    memReady<='0';
                    latchAinEn<='1';
                ELSIF writeReq='1' THEN
                    next_state<=WR_BUFFER;
                    latchDinEn<='1';
                    memReady<='1';
                    latchAinEn<='1';
                ELSE
                    next_state<=IDLE;
                    memReady<='1';
                END IF;
            WHEN WR_BUFFER=>
                --latchAin must stay up for 1 clock cycle
                latchAinEn<='0';
                memReady<='1';
                memResponse<='1';
                memRead<='0';
                memSelByte<=current_count;
                IF writeReq='1' THEN
                    next_count<=STD_LOGIC_VECTOR(UNSIGNED(current_count)+1);
                    next_state<=WR_BUFFER;
                    latchDinEn<='1';
                    memWrite<='0';
                ELSE
                    next_count<=current_count;
                    next_state<=MEM_WR;
                    latchDinEn<='0';
                    memWrite<='1';
                END IF;   
            WHEN MEM_WR=>
                latchAinEn<='0';
                memReady<='0';
                memResponse<='1';
                memRead<='0';
                memSelByte<=current_count;
                next_count<=(OTHERS=>'0');
                memWrite<='1';
                next_state<=IDLE;
                latchDinEn<='0';
            WHEN LATCH32=>
                latchAinEn<='1';
                latchDinEn<='0';
                memReady<='0';
                memResponse<='1';
                memRead<='1';
                memWrite<='0';
                memSelByte<=(OTHERS=>'0');
                next_state<=SERIAL_OUT;
                next_count<=(OTHERS=>'0');
            WHEN SERIAL_OUT=>
                latchAinEn<='0';
                latchDinEn<='0';
                memReady<='1';
                memResponse<='1';
                memRead<='0';
                memWrite<='0';
                memSelByte<=current_count;
                IF readReq='1' THEN
                    next_count<=STD_LOGIC_VECTOR(UNSIGNED(current_count)+1);
                    next_state<=SERIAL_OUT;
                ELSE
                    next_count<=(OTHERS=>'0');
                    next_state<=IDLE;
                END IF;
        END CASE;
    END PROCESS;

END behavior;


--memResponse should check errors in addressing (wrong address) parity error (?)






