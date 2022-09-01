-- **************************************************************************************
--	Filename:	bus_master_if.vhd
--	Project:	CNL_RISC-V
--  Version:	1.0
--	History:
--	Date:		31 Aug 2022
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
--	CNL_RISC-V microcontroller master/s hbus interface
--
-- **************************************************************************************
LIBRARY IEEE;
LIBRARY STD;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.NUMERIC_STD.ALL;

--CURRENTLY SUPPORTED SLAVES
--SSRAM --> (hselram)
--GPIO  --> (hselgpio)
--UART  --> (hseluart)


ENTITY bus_master_if IS
    GENERIC (
		busDataWidth      : INTEGER := 8;
		busAddressWidth   : INTEGER := 32
	); 
	PORT (
	    --system signals
		clk           : IN  STD_LOGIC;
		rst           : IN  STD_LOGIC;
		--input
		hready        : IN  STD_LOGIC;
		hresp         : IN  STD_LOGIC;
		hrdata        : IN  STD_LOGIC_VECTOR(busDataWidth-1 DOWNTO 0);
		--output
		haddr         : OUT STD_LOGIC_VECTOR(busAddressWidth-1 DOWNTO 0);
		hwrdata       : OUT STD_LOGIC_VECTOR(busDataWidth-1 DOWNTO 0);
		hwrite        : OUT STD_LOGIC;
		htrans        : OUT STD_LOGIC_VECTOR(1 DOWNTO 0);
		--slave select (size must be extended to the number of slaves)
		hselram       : OUT STD_LOGIC;
		hselflash     : OUT STD_LOGIC;
		hselgpio      : OUT STD_LOGIC;
		hseluart      : OUT STD_LOGIC;
		--interrupt signals
		platInterrupts: IN  STD_LOGIC_VECTOR (15 DOWNTO 0)
		);
END bus_master_if;

ARCHITECTURE behavior OF bus_master_if IS

    --core
    COMPONENT aftab_core IS
	GENERIC
		(len : INTEGER := 32);
	PORT
	(
		clk                      : IN  STD_LOGIC;
		rst                      : IN  STD_LOGIC;
		memReady       	         : IN  STD_LOGIC;
		memDataIn                : IN  STD_LOGIC_VECTOR (7 DOWNTO 0);
		memDataOut               : OUT STD_LOGIC_VECTOR (7 DOWNTO 0);
		memRead                  : OUT STD_LOGIC;
		memWrite                 : OUT STD_LOGIC;
		memAddr                  : OUT STD_LOGIC_VECTOR (len - 1 DOWNTO 0);
		--interrupt inputs and outputs
		machineExternalInterrupt : IN  STD_LOGIC;
		machineTimerInterrupt    : IN  STD_LOGIC;
		machineSoftwareInterrupt : IN  STD_LOGIC;
		userExternalInterrupt    : IN  STD_LOGIC;
		userTimerInterrupt       : IN  STD_LOGIC;
		userSoftwareInterrupt    : IN  STD_LOGIC;
		platformInterruptSignals : IN  STD_LOGIC_VECTOR (15 DOWNTO 0);
		interruptProcessing      : OUT STD_LOGIC
	);
    END COMPONENT;
    
    --read request
    SIGNAL coreReadReq: STD_LOGIC;
    --write request
    SIGNAL coreWriteReq: STD_LOGIC;
    --core interrupted
    SIGNAL coreOnInterrupt : STD_LOGIC;
    --interrupts (TODO)
    
    --decoder
    COMPONENT bus_sel_decoder IS
    GENERIC (
        addressWidth : INTEGER := 32
    );
    PORT (
        address      : IN  STD_LOGIC_VECTOR(31 DOWNTO 0);
        selRAM       : OUT STD_LOGIC;
        selFLASH     : OUT STD_LOGIC;
        selGPIO      : OUT STD_LOGIC;
        selUART      : OUT STD_LOGIC
    );
    END COMPONENT;
    
    SIGNAL selRAM: STD_LOGIC;
    SIGNAL selFLASH: STD_LOGIC;
    SIGNAL selGPIO: STD_LOGIC;
    SIGNAL selUART: STD_LOGIC;
    
    --htrans (BUS STATUS) controller
    TYPE BUS_STAT_TYPE IS (S_IDLE, S_READ, S_WRITE);
    SIGNAL curr_bus_state, next_bus_state: BUS_STAT_TYPE;
    
    SIGNAL haddr_cpy: STD_LOGIC_VECTOR(busAddressWidth-1 DOWNTO 0);
    
BEGIN

    --modified to be compatible with older version of Quartus
    haddr_cpy<=haddr;

    --######################################
    --TARGET PERIPHERAL SELECTION
    decoder: bus_sel_decoder
    GENERIC MAP(
        addressWidth=>busAddressWidth
    )
    PORT MAP(
        address=>haddr_cpy,
        selRAM =>selRAM,
        selFLASH=>selFLASH,
        selGPIO=>selGPIO,
        selUART=>selUART
    );
    
    hselram<=selRAM AND (coreReadReq OR coreWriteReq);
    hselflash<=selFLASH AND (coreReadReq OR coreWriteReq);
	hselgpio<=selGPIO AND (coreReadReq OR coreWriteReq);
	hseluart<=selUART AND (coreReadReq OR coreWriteReq);
	hwrite<='0' WHEN coreReadReq='1' ELSE
	        '1' WHEN coreWriteReq='1' ELSE
	        '0';
	--######################################
	
	--######################################
    --CORE
    core: aftab_core
	GENERIC MAP
		(len=>busAddressWidth)
	PORT MAP
	(
		clk=>clk,
		rst=>rst,
		memReady=>hready,
		memDataIn=>hrdata,
		memDataOut=>hwrdata,
		memRead=>coreReadReq,
		memWrite=>coreWriteReq,
		memAddr=>haddr,
		machineExternalInterrupt=>'0',
		machineTimerInterrupt=>'0',
		machineSoftwareInterrupt=>'0',
		userExternalInterrupt=>'0',
		userTimerInterrupt=>'0',
		userSoftwareInterrupt=>'0',
		platformInterruptSignals=>platInterrupts,
		interruptProcessing=>coreOnInterrupt
	);
    --######################################
  
	--######################################
	--BUS STATUS CONTROLLER
	PROCESS(clk, rst)
	BEGIN
	    IF rst='1' THEN
	        curr_bus_state<=S_IDLE;
	    ELSIF rising_edge(clk) THEN
	        curr_bus_state<=next_bus_state;
	    END IF;
	END PROCESS;    
	
	PROCESS(hselram, hselflash, hselgpio, hseluart, curr_bus_state, coreReadReq, coreWriteReq)
	BEGIN
	    CASE curr_bus_state IS
	        WHEN S_IDLE=>
	            htrans<="00";
	            IF( coreReadReq='1' AND (hselram='1' OR hselflash='1' OR hselgpio='1' OR hseluart='1') ) THEN
	                next_bus_state<=S_READ;
	            ELSIF( coreWriteReq='1' AND (hselram='1' OR hselflash='1' OR hselgpio='1' OR hseluart='1') ) THEN
	                next_bus_state<=S_WRITE;
	            ELSE
	                next_bus_state<=S_IDLE;
	            END IF;
	        WHEN S_READ=>
	            htrans<="01";
	            IF coreReadReq='1' THEN
	                next_bus_state<=S_READ;
	            ELSE
	                next_bus_state<=S_IDLE;
	            END IF;
	        WHEN S_WRITE=>
	            htrans<="10";
	            IF coreWriteReq='1' THEN
	                next_bus_state<=S_WRITE;
	            ELSE
	                next_bus_state<=S_IDLE;
	            END IF;
	    END CASE;
	END PROCESS;
    --######################################
    

END behavior;
