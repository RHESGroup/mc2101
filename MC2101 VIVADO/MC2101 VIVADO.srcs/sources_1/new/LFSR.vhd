-- **************************************************************************************
--	Filename:	LFSR.vhd
--	Project:	CNL_RISC-V
--  Version:	1.0
--	History:
--	Date:		23 December 2023
--
-- Copyright (C) 2023 CINI Cybersecurity National Laboratory
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
--	LFSR component
--
-- **************************************************************************************

LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE work.Constants.ALL;

ENTITY LFSR is
    GENERIC(
    Number_BitsLFSR : INTEGER := Number_BitsLFSR
    );
    PORT(
    Clk    : IN STD_LOGIC;
    Enable : IN STD_LOGIC;
 
    -- Optional Seed Value
    Seed_DV   : IN STD_LOGIC;
    Seed_Data : IN STD_LOGIC_VECTOR(Number_BitsLFSR-1 DOWNTO 0);
     
    LFSR_Data : OUT STD_LOGIC_VECTOR(Number_BitsLFSR-1 DOWNTO 0);
    LFSR_Done : OUT STD_LOGIC
    );
END ENTITY LFSR;
 
ARCHITECTURE structural OF LFSR IS
 
  SIGNAL r_LFSR : STD_LOGIC_VECTOR(Number_BitsLFSR DOWNTO 1) := (OTHERS => '0');
  SIGNAL w_XNOR : STD_LOGIC;
   
begin
 

  LFSR : PROCESS (Clk) IS
  BEGIN
    IF rising_edge(Clk) THEN
      IF Enable = '1' AND Seed_DV = '1'  THEN
        r_LFSR <= Seed_Data;
      ELSIF Enable = '1' AND Seed_DV = '0'  THEN
        r_LFSR <= r_LFSR(r_LFSR'left-1 DOWNTO 1) & w_XNOR;
      end if;
    end if;
  end process LFSR; 
 
  --Consideration for several different number of bits
  g_LFSR_3 : IF Number_BitsLFSR = 3 GENERATE
    w_XNOR <= r_LFSR(3) XNOR r_LFSR(2);
  END GENERATE g_LFSR_3;
 
  g_LFSR_4 : IF Number_BitsLFSR = 4 GENERATE
    w_XNOR <= r_LFSR(4) XNOR r_LFSR(3);
  END GENERATE g_LFSR_4;
 
  g_LFSR_5 : IF Number_BitsLFSR = 5 GENERATE
    w_XNOR <= r_LFSR(5) XNOR r_LFSR(3);
  END GENERATE g_LFSR_5;
 
  g_LFSR_6 : IF Number_BitsLFSR = 6 GENERATE
    w_XNOR <= r_LFSR(6) XNOR r_LFSR(5);
  END GENERATE g_LFSR_6;
 
  g_LFSR_7 : IF Number_BitsLFSR = 7 GENERATE
    w_XNOR <= r_LFSR(7) XNOR r_LFSR(6);
  END GENERATE g_LFSR_7;
 
  g_LFSR_8 : IF Number_BitsLFSR = 8 GENERATE
    w_XNOR <= r_LFSR(8) XNOR r_LFSR(6) xnor r_LFSR(5) xnor r_LFSR(4);
  END GENERATE g_LFSR_8;
 
  g_LFSR_9 : IF Number_BitsLFSR = 9 GENERATE
    w_XNOR <= r_LFSR(9) XNOR r_LFSR(5);
  END GENERATE g_LFSR_9;
 
  g_LFSR_10 : IF Number_BitsLFSR = 10 GENERATE
    w_XNOR <= r_LFSR(10) XNOR r_LFSR(7);
  END GENERATE g_LFSR_10;
 
  g_LFSR_11 : IF Number_BitsLFSR = 11 GENERATE
    w_XNOR <= r_LFSR(11) XNOR r_LFSR(9);
  END GENERATE g_LFSR_11;
 
  g_LFSR_12 : IF Number_BitsLFSR = 12 GENERATE
    w_XNOR <= r_LFSR(12) XNOR r_LFSR(6) xnor r_LFSR(4) xnor r_LFSR(1);
  END GENERATE g_LFSR_12;
 
  g_LFSR_13 : IF Number_BitsLFSR = 13 GENERATE
    w_XNOR <= r_LFSR(13) XNOR r_LFSR(4) xnor r_LFSR(3) xnor r_LFSR(1);
  END GENERATE g_LFSR_13;
 
  g_LFSR_14 : IF Number_BitsLFSR = 14 GENERATE
    w_XNOR <= r_LFSR(14) XNOR r_LFSR(5) xnor r_LFSR(3) xnor r_LFSR(1);
  END GENERATE g_LFSR_14;
 
  g_LFSR_15 : IF Number_BitsLFSR = 15 GENERATE
    w_XNOR <= r_LFSR(15) XNOR r_LFSR(14);
  END GENERATE g_LFSR_15;
 
  g_LFSR_16 : IF Number_BitsLFSR = 16 GENERATE
    w_XNOR <= r_LFSR(16) XNOR r_LFSR(15) xnor r_LFSR(13) xnor r_LFSR(4);
  END GENERATE g_LFSR_16;
 
  g_LFSR_17 : IF Number_BitsLFSR = 17 GENERATE
    w_XNOR <= r_LFSR(17) XNOR r_LFSR(14);
  END GENERATE g_LFSR_17;
 
  g_LFSR_18 : IF Number_BitsLFSR = 18 GENERATE
    w_XNOR <= r_LFSR(18) XNOR r_LFSR(11);
  END GENERATE g_LFSR_18;
 
  g_LFSR_19 : IF Number_BitsLFSR = 19 GENERATE
    w_XNOR <= r_LFSR(19) XNOR r_LFSR(6) xnor r_LFSR(2) xnor r_LFSR(1);
  END GENERATE g_LFSR_19;
 
  g_LFSR_20 : IF Number_BitsLFSR = 20 GENERATE
    w_XNOR <= r_LFSR(20) XNOR r_LFSR(17);
  END GENERATE g_LFSR_20;
 
   
  LFSR_Data <= r_LFSR(r_LFSR'left DOWNTO 1);
  LFSR_Done <= '1' WHEN r_LFSR(r_LFSR'left DOWNTO 1) = Seed_Data ELSE '0';
   
END ARCHITECTURE structural;