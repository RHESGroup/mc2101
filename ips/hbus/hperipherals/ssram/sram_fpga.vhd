-- **************************************************************************************
--	Filename:	ssram_test.vhd
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
--	ssram peripheral compatible with CycloneV Embedded Memories 
--  Quartus software maps this automatically on M10k blocks
-- **************************************************************************************


LIBRARY IEEE;
LIBRARY STD;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.NUMERIC_STD.ALL;

ENTITY ssram_fpga IS
	GENERIC (
		dataWidth      : INTEGER :=8;
		addressWidth   : INTEGER :=13
	);  
	PORT (
		clk           : IN  STD_LOGIC;
		readMem       : IN  STD_LOGIC;
		writeMem      : IN  STD_LOGIC;
		address       : IN  STD_LOGIC_VECTOR (addressWidth - 1 DOWNTO 0);
		dataIn     	  : IN  STD_LOGIC_VECTOR (dataWidth -1 DOWNTO 0);
		dataOut       : OUT STD_LOGIC_VECTOR (dataWidth -1 DOWNTO 0)
	);
END ssram_fpga;

--Behavior:
--Synchronous write
--Asynchronous read
--(also possible to make both processes Synchronous)

ARCHITECTURE behavior OF ssram_fpga IS

    TYPE mem_type IS ARRAY (0 TO 2**addressWidth - 1) OF STD_LOGIC_VECTOR (dataWidth-1 DOWNTO 0);
	SIGNAL mem : MEM_TYPE;
	SIGNAL dOut: STD_LOGIC_VECTOR (addressWidth - 1 DOWNTO 0);   

BEGIN

    --Synch write with enable
    PROCESS(clk)
    BEGIN
        IF (rising_edge(clk) and writeMem='1') THEN
            mem(TO_INTEGER(UNSIGNED(address))) <= dataIn;
        END IF;
    END PROCESS;
    
    --Asynch read with enable
    PROCESS(readMem, address)
    BEGIN
        IF readMem='1' then
			dOut <= mem(TO_INTEGER(UNSIGNED(address)));
        END IF;
    END PROCESS;
    
    dataOut<=dOut;

END behavior;



