----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 12/05/2023 09:14:02 AM
-- Design Name: 
-- Module Name: Constants - Behavioral
-- Project Name: 
-- Target Devices: 
-- Tool Versions: 
-- Description: 
-- 
-- Dependencies: 
-- 
-- Revision:
-- Revision 0.01 - File Created
-- Additional Comments:
-- 
--This file contains the constant values related to both AFTAB and MC2101
----------------------------------------------------------------------------------

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
	CONSTANT DATA_WIDTHFIFO:          INTEGER:=8;
    CONSTANT FIFO_DEPTH:              INTEGER:=16;
    CONSTANT LOG_FIFO_D:              INTEGER:=4;
    CONSTANT DATA_ERRORS:             INTEGER:=3; --(parity + framing + break are saved foreach received frame)
    


END Constants;

