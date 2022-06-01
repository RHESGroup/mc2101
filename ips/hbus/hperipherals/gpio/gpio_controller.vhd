-- **************************************************************************************
--	Filename:	gpio_controller.vhd
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
--	gpio peripheral controller
--
-- **************************************************************************************
LIBRARY IEEE;
LIBRARY STD;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.NUMERIC_STD.ALL;

ENTITY gpio_controller IS   
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
	    latchAin    :OUT STD_LOGIC;
	    gpio_ready  :OUT STD_LOGIC;
	    gpio_resp   :OUT STD_LOGIC
	);
END gpio_controller;

ARCHITECTURE behavior OF gpio_controller IS

    TYPE statetype IS (IDLE, MISAL, READ, WRITE);
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

    PROCESS(readReq, writeReq, addr_base, current_state)
    BEGIN
        CASE current_state IS
            WHEN IDLE =>
                latchAin<='0';
                gpio_read<='0';
	            gpio_write<='0';
	            shiftDout<='0';
	            gpio_ready<='1';
	            gpio_resp<='0';
	            shiftDin<='0';
	            IF readReq = '1'  THEN
	                IF addr_base="00" THEN
	                    gpio_read<='1';
	                    gpio_ready<='0';
	                    next_state<=READ;
	                ELSE
	                    gpio_ready<='0';
	                    next_state<=MISAL;
	                END IF;
	            ELSIF writeReq = '1' THEN
	                IF addr_base="00" THEN
	                    shiftDin<='1';
	                    next_state<=WRITE;
	                    latchAin<='1';
	                ELSE
	                    gpio_ready<='0';
	                    next_state<=MISAL;
	                END IF;
	            ELSE
	                next_state<=IDLE;
	            END IF;
            
            WHEN MISAL=>
                latchAin<='0';
                shiftDin<='0';
                gpio_read<='0';
	            gpio_write<='0';
	            shiftDout<='0';
                gpio_ready<='1';
                gpio_resp<='1';
                IF readReq = '1' OR writeReq = '1' THEN
                    next_state<=MISAL;
                ELSE
                    next_state<=IDLE;
                END IF;
            
            WHEN READ =>
                latchAin<='0';
                gpio_read<='0';
	            gpio_write<='0';
	            gpio_ready<='1';
	            gpio_resp<='0';
	            shiftDin<='0';
	            IF readReq = '1' THEN
	                next_state<=READ;
	                shiftDout<='1';
	            ELSE
	                next_state<=IDLE;
	                shiftDout<='0';
	            END IF;
	            
            WHEN WRITE=>
                latchAin<='0';
                gpio_read<='0';
	            gpio_ready<='1';
	            gpio_resp<='0';
	            shiftDout<='0';
	            IF writeReq = '1' THEN
	                next_state<=WRITE;
	                shiftDin<='1';
	                gpio_write<='0';
	            ELSE
	                next_state<=IDLE;
	                gpio_write<='1';
	                shiftDin<='0';
	                gpio_ready<='0';
	            END IF;
        END CASE;
    END PROCESS;
    
END behavior;







