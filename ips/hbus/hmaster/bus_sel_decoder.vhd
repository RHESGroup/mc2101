-- **************************************************************************************
--	Filename:	bus_sel_decoder.vhd
--	Project:	CNL_RISC-V
--  Version:	1.0
--	History:
--	Date:		30 Aug 2022
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
--	master/s interface's slave select decoder
--
-- **************************************************************************************
LIBRARY IEEE;
LIBRARY STD;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.NUMERIC_STD.ALL;

--this decoder is associated to a specific customized memory map

ENTITY bus_sel_decoder IS
    GENERIC (
        addressWidth : INTEGER := 32
    );
    PORT (
        address      : IN  STD_LOGIC_VECTOR(addressWidth-1 DOWNTO 0);
        selRAM       : OUT STD_LOGIC;
        selFLASH     : OUT STD_LOGIC;
        selGPIO      : OUT STD_LOGIC;
        selUART      : OUT STD_LOGIC
    );
END bus_sel_decoder;

ARCHITECTURE behavior OF bus_sel_decoder IS

    --SSRAM MEMORY MAP
    --INSTRUCTION RAM (8 KB)
    CONSTANT INSTRUCTIONS_START  : UNSIGNED(addressWidth-1 DOWNTO 0):=x"00000000";
    CONSTANT INSTRUCTIONS_END    : UNSIGNED(addressWidth-1 DOWNTO 0):=x"00002000";
    --DATA RAM (4 KB) + STACK (4 KB)
    CONSTANT DATA_START    : UNSIGNED(addressWidth-1 DOWNTO 0):=x"00100000";
    CONSTANT DATA_END      : UNSIGNED(addressWidth-1 DOWNTO 0):=x"00102000";
    --PERIPHERAL MEMORY MAP
    CONSTANT GPIO_START : UNSIGNED(addressWidth-1 DOWNTO 0):=x"1A100000";
    CONSTANT GPIO_END   : UNSIGNED(addressWidth-1 DOWNTO 0):=x"1A101000";
    CONSTANT UART_START : UNSIGNED(addressWidth-1 DOWNTO 0):=x"1A101000";
    CONSTANT UART_END   : UNSIGNED(addressWidth-1 DOWNTO 0):=x"1A102000";
    
BEGIN

    PROCESS(address)
    BEGIN
        IF( (UNSIGNED(address(addressWidth-1 DOWNTO 0))<INSTRUCTIONS_END) OR 
            (UNSIGNED(address(addressWidth-1 DOWNTO 0))>=DATA_START
            AND UNSIGNED(address)<DATA_END)
          ) THEN
            selRAM<='1'; 
            selGPIO<='0';
            selUART<='0';
        ELSIF( (UNSIGNED(address(addressWidth-1 DOWNTO 0))>=GPIO_START) AND 
               (UNSIGNED(address(addressWidth-1 DOWNTO 0))<GPIO_END) 
          ) THEN
            selRAM<='0';
            selGPIO<='1';
            selUART<='0';
        ELSIF( (UNSIGNED(address(addressWidth-1 DOWNTO 0))>=UART_START) AND 
               (UNSIGNED(address(addressWidth-1 DOWNTO 0))<UART_END)
          ) THEN
            selRAM<='0';
            selGPIO<='0';
            selUART<='1';
        ELSE
            selRAM<='0';
            selGPIO<='0';
            selUART<='0';
        END IF;
    END PROCESS;
    
    selFLASH<='0';

END behavior;
