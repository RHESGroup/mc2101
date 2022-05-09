-- **************************************************************************************
--	Filename:	ssram_test.vhd
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
--	ssram hbus peripheral example
--
-- **************************************************************************************
LIBRARY IEEE;
LIBRARY STD;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.NUMERIC_STD.ALL;
USE IEEE.STD_LOGIC_TEXTIO.ALL;
USE STD.TEXTIO.ALL;


ENTITY ssram_test IS
	GENERIC (
		dataWidth      : INTEGER := 32;
		addressWidth   : INTEGER := 32;
		actual_address : INTEGER := 13;
		size           : INTEGER := 2**actual_address -- 2^12 for data and 2^12 for instr, 4 K each
	);  
	PORT (
		clk           : IN  STD_LOGIC;
		rst           : IN  STD_LOGIC;
		readMem       : IN  STD_LOGIC;
		writeMem      : IN  STD_LOGIC;
		address       : IN  STD_LOGIC_VECTOR (addressWidth - 1 DOWNTO 0);
		dataIn     	  : IN  STD_LOGIC_VECTOR (dataWidth -1 DOWNTO 0);
		byteEn        : IN  STD_LOGIC_VECTOR (1 DOWNTO 0);
		dataOut       : OUT STD_LOGIC_VECTOR (dataWidth -1 DOWNTO 0)
	);
END ssram_test;


ARCHITECTURE behavior OF ssram_test IS
    
    TYPE mem_type IS ARRAY (0 TO size - 1) OF STD_LOGIC_VECTOR (dataWidth-1 DOWNTO 0);
	SIGNAL mem : MEM_TYPE;

	-- Memory boundaries - change this according to the linker script: sw/ref/link.common.ld
	CONSTANT base_iram : INTEGER := 16#00000#; 
	CONSTANT end_iram : INTEGER := 16#FFFFF#;
	
	CONSTANT base_dram : INTEGER := 16#100000#; 
	CONSTANT end_dram : INTEGER := 16#100600#;

	CONSTANT base_dram_actual : INTEGER := 16#1000#;
	CONSTANT size_dram : INTEGER := 16#0FFF#;
	
BEGIN

    process(rst, clk)
        variable adr: STD_LOGIC_VECTOR(actual_address-1 DOWNTO 0);
        VARIABLE memline             : LINE;
		VARIABLE memline_log         : LINE;
		VARIABLE err_check           : FILE_OPEN_STATUS;
		VARIABLE linechar	         : CHARACTER;
		VARIABLE read_address	     : STD_LOGIC_VECTOR (31 DOWNTO 0);
		VARIABLE read_data           : STD_LOGIC_VECTOR (31 DOWNTO 0);
		FILE f                       : TEXT;
    begin
        if rst='1' then
            --mem <= (others => (others => '0'));
            -- Load memory content from file
			--mem <= (OTHERS => (OTHERS => '0'));
			FILE_OPEN(err_check, f, ("./slm_files/spi_stim.txt"), READ_MODE);
			IF err_check = open_ok THEN
				WHILE NOT ENDFILE (f) LOOP
					READLINE (f, memline);
					HREAD (memline, read_address);
					READ (memline, linechar); -- read character '_' 
					HREAD (memline, read_data);
					IF UNSIGNED(read_address) > end_iram THEN -- it is a data address (see file link.common.ld)
						adr := '1' & read_address(actual_address-2 DOWNTO 0);
					ELSE -- it is a program address
						adr := '0' & read_address(actual_address-2 DOWNTO 0);
					END IF;
					mem(TO_INTEGER(UNSIGNED(adr)))<=read_data;
				END LOOP;
				FILE_CLOSE (f);
			END IF;
        elsif (rising_edge(clk) and readMem='1') then
            if UNSIGNED(address) > end_iram then 
		        adr := '1' & address(actual_address-2 downto 0);
			else
				adr := '0' & address(actual_address-2 downto 0);
			end if;
			--always read 32 bit
			dataOut <= mem(TO_INTEGER(UNSIGNED(adr)));
	    elsif (rising_edge(clk) and writeMem='1') then
			if UNSIGNED(address) > end_iram then 
	            adr := '1' & address(actual_address-2 downto 0);
				IF byteEn="00" THEN
				    --write byte
				    mem(TO_INTEGER(UNSIGNED(adr)))(7 DOWNTO 0) <= dataIn(7 DOWNTO 0);
				ELSIF byteEn="01" THEN
				    --write half word
				    mem(TO_INTEGER(UNSIGNED(adr)))(15 DOWNTO 0) <= dataIn(15 DOWNTO 0);
				ELSE
				    --write word
				    mem(TO_INTEGER(UNSIGNED(adr)))(31 DOWNTO 0) <= dataIn(31 DOWNTO 0);
				END IF;
			end if;
			-- writing on instruction portion is inhibited
        end if;
    end process;


END behavior;
