-- **************************************************************************************
--	Filename:	ssram_bus_wrap.vhd
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
--	ssram hbus peripheral wrapper
--
-- **************************************************************************************
LIBRARY IEEE;
LIBRARY STD;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.NUMERIC_STD.ALL;


ENTITY ssram_bus_wrap IS
	GENERIC (
		busDataWidth      : INTEGER := 8;
		busAddressWidth   : INTEGER := 32
	);  
	PORT (
	    --system signals
		clk           : IN  STD_LOGIC;
		rst           : IN  STD_LOGIC;
		--master driven signals
		htrans        : IN  STD_LOGIC_VECTOR(1 DOWNTO 0);
		hselx         : IN  STD_LOGIC;
		hwrite        : IN  STD_LOGIC;
		hwrdata       : IN  STD_LOGIC_VECTOR(busDataWidth-1 DOWNTO 0);
		haddr         : IN  STD_LOGIC_VECTOR(busAddressWidth-1 DOWNTO 0);
		--slave driven signals
		hrdata        : OUT STD_LOGIC_VECTOR(busDataWidth-1 DOWNTO 0);
		hready        : OUT STD_LOGIC;
		hresp         : OUT STD_LOGIC
	);
END ssram_bus_wrap;


ARCHITECTURE behavior OF ssram_bus_wrap IS

    --ssram
    COMPONENT ssram_test IS
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
    END COMPONENT;
    
    SIGNAL readMem: STD_LOGIC;
    SIGNAL writeMem: STD_LOGIC;
    SIGNAL address: STD_LOGIC_VECTOR (busAddressWidth - 1 DOWNTO 0);
    SIGNAL dataIn: STD_LOGIC_VECTOR (31 DOWNTO 0);
    SIGNAL dataOut: STD_LOGIC_VECTOR (31 DOWNTO 0);
    SIGNAL ready: STD_LOGIC;
    
    
    --controller
    COMPONENT ssram_controller IS 
	PORT (
	    --system signals
		clk           : IN  STD_LOGIC;
		rst           : IN  STD_LOGIC;
		--input
		chip_select   : IN  STD_LOGIC;
		request       : IN  STD_LOGIC;
		--output
		memRead       : OUT STD_LOGIC;
		memWrite      : OUT STD_LOGIC;
		memSelByte    : OUT STD_LOGIC_VECTOR(1 DOWNTO 0);
		memResponse   : OUT STD_LOGIC;
		latchInEn     : OUT STD_LOGIC;
		memReady      : OUT STD_LOGIC
	);
    END COMPONENT;
    
    SIGNAL chip_select: STD_LOGIC;
    SIGNAL request: STD_LOGIC;
    SIGNAL latchInEn: STD_LOGIC;
    --serial out mux
    SIGNAL memSelByte: STD_LOGIC_VECTOR(1 DOWNTO 0);
    --serial out bytes
    SIGNAL byteLSBout, byteLSB1out, byteLSB2out, byteLSB3out: STD_LOGIC_VECTOR (7 DOWNTO 0);
    --serial in buffer
    SIGNAL byteLSBin, byteLSB1in, byteLSB2in, byteLSB3in: STD_LOGIC_VECTOR (7 DOWNTO 0);
    
BEGIN

    memory: ssram_test
	GENERIC MAP(
		dataWidth      => 32,
		addressWidth   => busAddressWidth,
		actual_address => 13,
		size           => 2**13
	)  
	PORT MAP(
		clk            =>clk,
		rst            =>rst,
		readMem        =>readMem,
		writeMem       =>writeMem,
		address        =>haddr,
		dataIn     	   =>dataIn,
		byteEN         =>memSelByte,
		dataOut        =>dataOut		   
	);
    
    controller: ssram_controller 
	PORT MAP(
		clk            =>clk,
		rst            =>rst,
		chip_select    =>hselx,
		request        =>hwrite,
		memRead        =>readMem,
		memWrite       =>writeMem,
		memSelByte     =>memSelByte,
		memResponse    =>hresp,
		latchInEn      =>latchInEn,
		memReady       =>hready
	);

    --output bytes
    byteLSBout  <= dataOut(7 DOWNTO 0);
    byteLSB1out <= dataOut(15 DOWNTO 8);
    byteLSB2out <= dataOut(23 DOWNTO 16);
    byteLSB3out <= dataOut(31 DOWNTO 24);
    
    --mux serial out
    hrdata   <= byteLSBout  WHEN memSelByte="00" ELSE
                byteLSB1out WHEN memSelByte="01" ELSE
                byteLSB2out WHEN memSelByte="10" ELSE
                byteLSB3out;
             
    --serial in buffer
    PROCESS(clk, rst, writeMem, hwrdata)
    BEGIN
        IF rst='1' THEN
            byteLSBin<=(OTHERS=>'0');
            byteLSB1in<=(OTHERS=>'0');
            byteLSB2in<=(OTHERS=>'0');
            byteLSB3in<=(OTHERS=>'0');
        ELSIF rising_edge(clk) THEN
            IF latchInEn='1' THEN
                byteLSBin<=hwrdata;
                byteLSB1in<=byteLSBin;
                byteLSB2in<=byteLSB1in;
                byteLSB3in<=byteLSB2in;
            END IF;
        END IF;
    END PROCESS;
    
    dataIn<=byteLSB3in & byteLSB2in & byteLSB1in & byteLSBin;
    

END behavior;
