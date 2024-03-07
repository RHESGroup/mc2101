-- **************************************************************************************
--	Filename:	uart_controller.vhd
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
--	uart peripheral controller
--
-- **************************************************************************************

LIBRARY IEEE;
LIBRARY STD;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.NUMERIC_STD.ALL;

ENTITY uart_controller IS   
	PORT (
	    clk         :IN STD_LOGIC;
	    rst         :IN STD_LOGIC;
	    --Input signals
	    chip_select :IN  STD_LOGIC;
		request     :IN  STD_LOGIC;
		--Output signals
	    uart_read   :OUT STD_LOGIC;
	    uart_write  :OUT STD_LOGIC;
	    uart_ready  :OUT STD_LOGIC;
	    uart_resp   :OUT STD_LOGIC
	);
END uart_controller;

ARCHITECTURE behavior OF uart_controller IS

    TYPE statetype IS (IDLE, READ, WRITE);
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
    
    readReq<=chip_select and (not request); -- '1' if the UART has been selected and it is a READ request
    writeReq<=chip_select and request; --'1' if the UART has been selected and it is a WRITE request

    PROCESS(readReq, writeReq, current_state)
    BEGIN
    uart_read<='0';
	uart_write<='0';
	uart_ready<='1';
    uart_resp<='0';
        CASE current_state IS
            WHEN IDLE =>
	            IF readReq = '1'  THEN
	                uart_read<='1';
	                next_state<=READ;
	            ELSIF writeReq = '1' THEN
	                next_state<=WRITE;
	                uart_write<='1';
	            ELSE
	                next_state<=IDLE;
	            END IF;
            
            WHEN READ =>
	            IF readReq = '1' THEN
	                next_state<=READ;
	            ELSE
	                next_state<=IDLE;
	            END IF;
	            
            WHEN WRITE=>
	            IF writeReq = '1' THEN
	                next_state<=WRITE;
	            ELSE
	                next_state<=IDLE;
	            END IF;
	        WHEN OTHERS=>
	            uart_read<='0';
	            uart_write<='0';
	            next_state<=IDLE;
	              
        END CASE;
    END PROCESS;
    

    
END behavior;





