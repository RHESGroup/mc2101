-- **************************************************************************************
--	Filename:	counter.vhd
--	Project:	CNL_RISC-V
--  Version:	1.0
--	History:
--	Date:		13 May 2022
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
--	Generic behavioral counter
--
-- **************************************************************************************

LIBRARY IEEE;
LIBRARY STD;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.NUMERIC_STD.ALL;

ENTITY counter IS
    GENERIC (
		size    : INTEGER:=16   
	); 
	PORT (
	    clk     : IN  STD_LOGIC; 
	    rst     : IN  STD_LOGIC; 
	    enable  : IN  STD_LOGIC; 
	    clear   : IN  STD_LOGIC; 
	    cOut    : OUT STD_LOGIC_VECTOR(size-1 DOWNTO 0) 
		);
END counter;

ARCHITECTURE behavior OF counter IS

    SIGNAL value: UNSIGNED(size-1 DOWNTO 0);

BEGIN

    PROCESS(clk, rst)
    BEGIN
        IF (rst='1' or clear='1') THEN
            value<=(OTHERS=>'0');
        ELSIF (rising_edge(clk) and enable='1') THEN
            value<=(value+1);
        END IF;
    END PROCESS;
    
    cOut<=STD_LOGIC_VECTOR(value);

END behavior;
