-- **************************************************************************************
--	Filename:	gpio_controller.vhd
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
--	gpio peripheral controller
--
-- **************************************************************************************
LIBRARY IEEE;
LIBRARY STD;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.NUMERIC_STD.ALL;

ENTITY gpio_controller IS   
	PORT (
	    --INPUTS
	    clk         :IN STD_LOGIC;
	    rst         :IN STD_LOGIC;
	    chip_select :IN  STD_LOGIC; --Enables the peripheral
		request     :IN  STD_LOGIC; --Indicates the transfer direction. Write(1) or Read(0)
	    addr_base   :IN STD_LOGIC_VECTOR(1 DOWNTO 0);
	    --OUTPUTS
	    gpio_read   :OUT STD_LOGIC;
	    gpio_write  :OUT STD_LOGIC;
	    shiftDout   :OUT STD_LOGIC;
	    shiftDin    :OUT STD_LOGIC;
	    latchAin    :OUT STD_LOGIC;
	    gpio_ready  :OUT STD_LOGIC;
	    clear       :OUT STD_LOGIC;
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
    
    readReq<=chip_select and (not request); -- '1' if the GPIO has been selected and it is a READ request
    writeReq<=chip_select and request; --'1' if the GPIO has been selected and it is a WRITE request

    PROCESS(readReq, writeReq, addr_base, current_state)
    BEGIN
    clear<='0';
    latchAin<='0';
    gpio_read<='0';
    gpio_write<='0';
    shiftDout<='0';
    gpio_ready<='1';
    gpio_resp<='0';
    shiftDin<='0';
        CASE current_state IS
            WHEN IDLE => --We stay in IDLE unless we receive a request(write or read)
	            IF readReq = '1'  THEN --If the operation requested is a READ...
	                IF addr_base="00" THEN
	                    latchAin<='1';
	                    gpio_read<='1'; --Indicates the GPIO core that we want to read
	                    gpio_ready<='0';
	                    next_state<=READ;
	                ELSE
	                    --BUS FAULT (hready=0 AND hresp=1)
	                    gpio_ready<='0';
	                    gpio_resp<='1';
	                    next_state<=MISAL;
	                END IF;
	            ELSIF writeReq = '1' THEN --If the operation requested is a WRITE...
	                IF addr_base="00" THEN
	                    shiftDin<='1';
	                    next_state<=WRITE;
	                    latchAin<='1';
	                ELSE    
	                    --BUS FAULT (hready=0 AND hresp=1)
	                    gpio_ready<='0';
	                    gpio_resp<='1';
	                    next_state<=MISAL;
	                END IF;
	            ELSE
	                next_state<=IDLE;
	            END IF;
            
            WHEN MISAL=>
                --FAULTY STATE:
                --  KEEP hresp=1 for 1 clock period
                --  RELEASE hready
                gpio_resp<='1';

                IF readReq = '1' OR writeReq = '1' THEN
                    next_state<=MISAL;
                ELSE
                    next_state<=IDLE;
                END IF;
            
            WHEN READ =>
	            IF readReq = '1' THEN
	                next_state<=READ;
	                shiftDout<='1';
	                clear<='0';
	            ELSE
	                next_state<=IDLE;
	                shiftDout<='0';
	                clear<='1';
	            END IF;
	            
            WHEN WRITE=>
	            IF writeReq = '1' THEN
	                next_state<=WRITE;
	                shiftDin<='1';
	                gpio_write<='0';
	                clear<='0';
	            ELSE
	                next_state<=IDLE;
	                gpio_write<='1'; --Indicates the GPIO core that we want to write
	                shiftDin<='0';
	                gpio_ready<='0';
	                clear<='1';
	            END IF;
	        WHEN OTHERS=>
	            clear<='0';
                latchAin<='0';
                gpio_read<='0';
                gpio_write<='0';
                shiftDout<='0';
                gpio_ready<='1';
                gpio_resp<='0';
                shiftDin<='0';
                next_state<=IDLE;
	        
        END CASE;
    END PROCESS;
    
END behavior;







