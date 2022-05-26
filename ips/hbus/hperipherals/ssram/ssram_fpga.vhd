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
USE IEEE.STD_LOGIC_TEXTIO.ALL;
USE STD.TEXTIO.ALL;

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
--Synchronous read
--(both process needs to be Synchronous otherwise the memory is not synthesized in the fpga memories)

ARCHITECTURE behavior OF ssram_fpga IS 

    TYPE MEM_TYPE IS ARRAY (0 TO 2**addressWidth - 1) OF STD_LOGIC_VECTOR (dataWidth-1 DOWNTO 0);
	
	FUNCTION init_my_ram (filename : string) RETURN MEM_TYPE IS
    FILE f : TEXT;
    VARIABLE m : MEM_TYPE;
    VARIABLE adr: STD_LOGIC_VECTOR(addressWidth-1 DOWNTO 0);
	VARIABLE memline: LINE;
	VARIABLE linechar: CHARACTER;
	VARIABLE read_address: STD_LOGIC_VECTOR (31 DOWNTO 0);
	VARIABLE read_data: STD_LOGIC_VECTOR (31 DOWNTO 0);
	VARIABLE index: INTEGER:=0;
	VARIABLE end_iram : INTEGER := 16#FFFFF#;
    BEGIN
        file_open(f, filename, read_mode);
        for index in MEM_TYPE'range loop
            IF ENDFILE(f) THEN
                exit;
            END IF;
	        READLINE (f, memline);
			HREAD (memline, read_address);
			READ (memline, linechar); -- read character '_' 
		    HREAD (memline, read_data);
		    IF UNSIGNED(read_address) > end_iram THEN -- it is a data address (see file link.common.ld)
			    adr := '1' & read_address(addressWidth-2 DOWNTO 0);
			ELSE -- it is a program address
				adr := '0' & read_address(addressWidth-2 DOWNTO 0);
			END IF;
				m(TO_INTEGER(UNSIGNED(adr))) 	 := read_data(7 DOWNTO 0);
				m(TO_INTEGER(UNSIGNED(adr) + 1)) := read_data(15 DOWNTO 8);
				m(TO_INTEGER(UNSIGNED(adr) + 2)) := read_data(23 DOWNTO 16);
				m(TO_INTEGER(UNSIGNED(adr) + 3)) := read_data(31 DOWNTO 24);
		END LOOP;
		FILE_CLOSE (f);
        RETURN m;
    END init_my_ram;
   
	SIGNAL mem : MEM_TYPE:=init_my_ram("./slm_files/spi_stim.txt"); 

BEGIN

    --Synch write with enable
    PROCESS(clk)
    BEGIN
        IF (rising_edge(clk) and writeMem='1') THEN
            mem(TO_INTEGER(UNSIGNED(address))) <= dataIn;
        END IF;
    END PROCESS;
      
    --Synch read with enable
    PROCESS(clk)
    BEGIN
        IF (falling_edge(clk) and readMem='1') THEN
            dataOut <= mem(TO_INTEGER(UNSIGNED(address)));
        END IF;
    END PROCESS;

END behavior;


