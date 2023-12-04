-- **************************************************************************************
--	Filename:	aftab_csr_isl.vhd
--	Project:	CNL_RISC-V
--  Version:	1.0
--	Date:		05 April 2022
--
-- Copyright (C) 2022 CINI Cybersecurity National Laboratory and University of Tehran
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
-- File content description:
-- Input selection logic for Control and Status Registers in the AFTAB core
-- The CSRISL prepares input data for CSR registers
-- **************************************************************************************

LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.STD_LOGIC_UNSIGNED.ALL;
ENTITY aftab_csr_isl IS
	GENERIC
		(len : INTEGER := 32);
	PORT
	(
	    --INPUTS
		selP1                          : IN  STD_LOGIC; --INPUT coming from the Control Unit
		selIm                          : IN  STD_LOGIC; --INPUT coming from the Control Unit
		selReadWrite                   : IN  STD_LOGIC; --INPUT coming from the Control Unit
		clr                            : IN  STD_LOGIC; 
		set                            : IN  STD_LOGIC;
		selPC                          : IN  STD_LOGIC; --INPUT coming from the Control Unit
		selmip                         : IN  STD_LOGIC; --INPUT coming from the Control Unit
		selCause                       : IN  STD_LOGIC; --INPUT coming from the Control Unit
		selTval                        : IN  STD_LOGIC; --INPUT coming from the Control Unit
		machineStatusAlterationPreCSR  : IN  STD_LOGIC; --INPUT coming from the Control Unit
		userStatusAlterationPreCSR     : IN  STD_LOGIC; --INPUT coming from the Control Unit
		machineStatusAlterationPostCSR : IN  STD_LOGIC; --INPUT coming from the Control Unit
		userStatusAlterationPostCSR    : IN  STD_LOGIC; --INPUT coming from the Control Unit
		mirrorUstatus                  : IN  STD_LOGIC; --INPUT coming from the Register Bank
		mirrorUie                      : IN  STD_LOGIC; --INPUT coming from the Register Bank
		mirrorUip                      : IN  STD_LOGIC; --INPUT coming from the Register Bank
		mirrorUser                     : IN  STD_LOGIC; --INPUT coming from the Control Unit
		curPRV                         : IN  STD_LOGIC_VECTOR(1 DOWNTO 0); --INPUT coming from the ICCD(Interrupt Check and Cause detection). This signal is associated with the current Privilege mode
		ir19_15                        : IN  STD_LOGIC_VECTOR(4 DOWNTO 0); --INPUT coming from the IR(instruction register)
		CCmip                          : IN  STD_LOGIC_VECTOR(len - 1 DOWNTO 0); --INPUT coming from the interSrcSynchReg(ISSR)(signal called CCmip). It consists of the interrupts sources(32 bits)
		causeCode                      : IN  STD_LOGIC_VECTOR(len - 1 DOWNTO 0); --INPUT coming from the ICCD
		trapValue                      : IN  STD_LOGIC_VECTOR(len - 1 DOWNTO 0); --INPUT coming from the ICCD
		P1                             : IN  STD_LOGIC_VECTOR(len - 1 DOWNTO 0); --INPUT coming from the Register File
		PC                             : IN  STD_LOGIC_VECTOR(len - 1 DOWNTO 0); --INPUT coming from the PC
		outCSR                         : IN  STD_LOGIC_VECTOR(len - 1 DOWNTO 0); --INPUT coming from the Register bank
		--OUTPUTS
		previousPRV                    : OUT STD_LOGIC_VECTOR(1 DOWNTO 0); --OUTPUT going to the Control Unit
		inCSR                          : OUT STD_LOGIC_VECTOR(len - 1 DOWNTO 0) --OUTPUT going to the Register Bank
	);
END ENTITY aftab_csr_isl;
--
ARCHITECTURE behavioral OF aftab_csr_isl IS
	SIGNAL orRes, andRes, regOrImm, preInCSR : STD_LOGIC_VECTOR(len - 1 DOWNTO 0);
BEGIN 
    --For further understanding, see page 13(last part of the table) of the AFTAB User manual
    --This signal selects between rs1(P1) and the uimm5 which is extended to 32 bits
	regOrImm <= P1 WHEN selP1 = '1' ELSE
		("000000000000000000000000000" & ir19_15) WHEN selIm = '1' ELSE (OTHERS => '0');
	---This signal computes either csr | rs1 or csr | uimm5(extended) depending on the value of regOrImm
	--With this, rs1 works a bit mask that specifies the bit to be set in the csr
	orRes    <= outCSR OR regOrImm;
	---This signal computes either csr & !rs1 or csr & !uimm5(extended) depending on the value of regOrImm
	--With this, rs1 works a bit mask that specifies the bit to be clear in the csr
	andRes   <= outCSR AND (NOT regOrImm);
	
	preInCSR <= regOrImm WHEN selReadWrite = '1' ELSE --When the instruction is csrrw or csrrwi
		orRes WHEN set = '1' ELSE --When the instruction is csrrs or csrrsi
		andRes WHEN clr = '1' ELSE --When the instruction is csrrc or csrrci
		CCmip WHEN selmip = '1' ELSE
		causeCode WHEN selCause = '1' ELSE --Encoding of the interrupt or exception cause
		trapValue WHEN selTval = '1' ELSE --When an exception has occurred, we need to send the trapValue to update either the Machine trap Value(MTVAL) or the User trap Value(UTVAL)
		PC WHEN selPC = '1' ELSE 
		(outCSR(31 DOWNTO 13) & curPRV & outCSR(10 DOWNTO 8) & outCSR(3) & outCSR(6 DOWNTO 4) & '0' & outCSR(2 DOWNTO 0)) WHEN machineStatusAlterationPreCSR = '1' ELSE --JUAN: I change this as it originally was
		--(outCSR(31 DOWNTO 13) & previousPRV & outCSR(10 DOWNTO 8) & outCSR(3) & outCSR(6 DOWNTO 4) & '0' & outCSR(2 DOWNTO 0)) WHEN machineStatusAlterationPreCSR = '1' ELSE --changed luca, MPP is substituted with prevPRV 
		(outCSR(31 DOWNTO 5) & outCSR(0) & outCSR(3 DOWNTO 1) & '0') WHEN userStatusAlterationPreCSR = '1' ELSE
		(outCSR(31 DOWNTO 8) & '0' & outCSR(6 DOWNTO 4) & '1' & outCSR(2 DOWNTO 0)) WHEN machineStatusAlterationPostCSR = '1' ELSE
		(outCSR(31 DOWNTO 5) & '0' & outCSR(3 DOWNTO 1) & '1') WHEN userStatusAlterationPostCSR = '1' ELSE
		(OTHERS => '0');
		
	inCSR <= (preInCSR AND X"00000011") WHEN (mirrorUser = '1' AND mirrorUstatus = '1')ELSE
		(preInCSR AND X"00000111") WHEN (mirrorUser = '1' AND (mirrorUie = '1' OR mirrorUip = '1')) ELSE preInCSR;
	
	--IF outCSR(12 DOWNTO 11) = "11", machime mode is the PreviousPRV. IF outCSR(12 DOWNTO 11) = "00", user mode is the PreviousPRV
	previousPRV <= outCSR(12 DOWNTO 11); --These bits correspond to the Machine Previous Privilege mode(MPP) field of the XSTATUS register
END ARCHITECTURE behavioral;
