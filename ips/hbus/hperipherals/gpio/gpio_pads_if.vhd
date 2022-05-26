-- **************************************************************************************
--	Filename:	gpio_pads_if.vhd
--	Project:	CNL_RISC-V
--  Version:	1.0
--	History:
--	Date:		26 May 2022
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
--	gpio pads interface: interface to bidirectional bus connected to physical pins
--
-- **************************************************************************************
LIBRARY IEEE;
LIBRARY STD;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.NUMERIC_STD.ALL;

ENTITY gpio_pads_if IS   
    GENERIC (
        BUFFERSIZE: integer:=32
    );
	PORT (
	    gpio_pins:  INOUT STD_LOGIC_VECTOR( BUFFERSIZE-1 DOWNTO 0);
	    gpio_port_in : OUT STD_LOGIC_VECTOR( BUFFERSIZE-1 DOWNTO 0);
	    gpio_pad_dir : IN STD_LOGIC_VECTOR( BUFFERSIZE-1 DOWNTO 0);
	    gpio_port_out: IN STD_LOGIC_VECTOR( BUFFERSIZE-1 DOWNTO 0)
	);
END gpio_pads_if;

ARCHITECTURE behavior OF gpio_pads_if IS
BEGIN

    PROCESS(gpio_pad_dir, gpio_port_out, gpio_pins)
    BEGIN
        FOR i IN 0 TO (BUFFERSIZE-1) LOOP
            IF gpio_pad_dir(i) = '0' THEN
                gpio_port_in(i)<=gpio_pins(i); --is this multiplexer needed?
                gpio_pins(i)<='Z';
            ELSE
                gpio_port_in(i)<='0'; --is this multiplexer needed?
                gpio_pins(i)<=gpio_port_out(i);
            END IF;
            --COMPATIBLE ONLY WITH VHDL 2008+
            --gpio_port_in(i)<=gpio_pins(i) WHEN gpio_pad_dir(i) = '0' ELSE '0';
            --gpio_pins(i)<=gpio_port_out(i) WHEN gpio_pad_dir(i) = '1' ELSE 'Z';
        END LOOP;
    END PROCESS;
    
END behavior;
