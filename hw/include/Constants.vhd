-- **************************************************************************************
--	Filename:	Constants.vhd
--	Project:	CNL_RISC-V
--  Version:	1.0
--	History:
--	Date:		27 Dec 2023
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
--	This file contains the constant values related to both AFTAB and MC2101
--
-- **************************************************************************************

LIBRARY IEEE; 
USE IEEE.STD_LOGIC_1164.ALL;

PACKAGE Constants IS
    
    --AFTAB CONSTANTS

    --Constants related to AFTAB memory
    
    CONSTANT dataWidth      : INTEGER := 8;
	CONSTANT addressWidth   : INTEGER := 32;
	CONSTANT actual_address : INTEGER := 13;
	CONSTANT size           : INTEGER := 2 ** actual_address; -- 2^12 for data and 2^12 for instr, 4 K each  
    -- Memory boundaries - change this according to the linker script: sw/ref/link.common.ld
	CONSTANT base_iram : INTEGER := 16#00000#; 
	CONSTANT end_iram : INTEGER := 16#FFFFF#;

	CONSTANT base_dram : INTEGER := 16#100000#; 
	CONSTANT end_dram : INTEGER := 16#100600#;

	CONSTANT base_dram_actual : INTEGER := 16#1000#;
	CONSTANT size_dram : INTEGER := 16#0FFF#;
	
	--MC2101 CONSTANTS
	
	--Constants related to MC2101
    CONSTANT dataWidthSRAM:           INTEGER :=8;
	CONSTANT addressWidthSRAM:        INTEGER :=13;
	
	--Oonstants related to UART
	--FIFO
	CONSTANT DATA_WIDTHFIFO:          INTEGER:=8; --Maximun data word length
    CONSTANT FIFO_DEPTH:              INTEGER:=16; --Size of the FIFO buffer
    CONSTANT LOG_FIFO_D:              INTEGER:=4;
    CONSTANT DATA_ERRORS:             INTEGER:=3; --(parity + framing + break are saved foreach received frame)
    
    --Constants related to testbenches
    CONSTANT ClockPeriod :            TIME := 20 ns;
    CONSTANT Number_BitsLFSR :        INTEGER := 20;

	--Constants related to the BRAM
	CONSTANT Physical_size :          INTEGER := 14;
END Constants;

