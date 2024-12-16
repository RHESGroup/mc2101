-- **************************************************************************************
--	Filename:	gpio_core.vhd
--	Project:	CNL_RISC-V
--  Version:	1.0
--	History:
--	Date:		9 Sep 2022
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
--	gpio peripheral core
--
-- **************************************************************************************

LIBRARY IEEE;
LIBRARY STD;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.NUMERIC_STD.ALL;

--GPIO CORE REGISTERS:
--| ADDRESS |   NAME   |
--| 0x0000  | PADDIR   |
--| 0x0004  | PADIN    |
--| 0x0008  | PADOUT   |
--| 0x000C  | PADEN    |
--| 0x0010  | PADINTEN |
--| 0x0014  | INTTYPE0 |
--| 0x0018  | INTTYPE1 |
--| 0x001C  | INTSTATUS|
--TOT BYTES: 32
--REQUIRED ADDRESS WIDTH: 32
--BYTE ADDRESSABLE PERIPHERAL: NOT

ENTITY gpio_core IS   
	PORT (
	    --INPUTS
		clk           : IN  STD_LOGIC;
		rst           : IN  STD_LOGIC;
		address       : IN  STD_LOGIC_VECTOR(4 DOWNTO 0); 
		busDataIn     : IN  STD_LOGIC_VECTOR(31 DOWNTO 0);
		read          : IN  STD_LOGIC;
		write         : IN  STD_LOGIC;
	    gpio_in_async : IN  STD_LOGIC_VECTOR(31 DOWNTO 0);
		--OUTPUTS
		busDataOut    : OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
		interrupt     : OUT STD_LOGIC;
		gpio_out_sync : OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
		gpio_pad_dir  : OUT STD_LOGIC_VECTOR(31 DOWNTO 0)
	);

END gpio_core;

ARCHITECTURE behavior OF gpio_core IS

    --GPIO REGISTERS
    SIGNAL PADDIR    : STD_LOGIC_VECTOR(31 DOWNTO 0); --Controls the direction of each of the GPIO pads
    SIGNAL PADIN     : STD_LOGIC_VECTOR(31 DOWNTO 0); --Saves the input values coming from input pins
    SIGNAL PADOUT    : STD_LOGIC_VECTOR(31 DOWNTO 0); --Drives the output lines with its content
    SIGNAL PADEN     : STD_LOGIC_VECTOR(31 DOWNTO 0); --Enables the GPIOs
    SIGNAL PADINTEN  : STD_LOGIC_VECTOR(31 DOWNTO 0); --Interrupt enable bits for input lines
    SIGNAL INTTYPE0  : STD_LOGIC_VECTOR(31 DOWNTO 0); --Controls the interrupt triggering behavior of each interrupt-enabled pin
    SIGNAL INTTYPE1  : STD_LOGIC_VECTOR(31 DOWNTO 0); --Controls the interrupt triggering behavior of each interrupt-enabled pin
    SIGNAL INTSTATUS : STD_LOGIC_VECTOR(31 DOWNTO 0); --Contains interrupt status for each GPIO line
    --Async input synchronization registers DOUBLE SYNCHRONIZER
    SIGNAL gpio_in_sync1 : STD_LOGIC_VECTOR(31 DOWNTO 0);
    SIGNAL gpio_in_sync2 : STD_LOGIC_VECTOR(31 DOWNTO 0);
    --Effective address (registers are only 32-byte addressable)
    SIGNAL eff_addr: STD_LOGIC_VECTOR(2 DOWNTO 0);
    --SIGNALS USED FOR INTERRUPTS
    SIGNAL risings  : STD_LOGIC_VECTOR(31 DOWNTO 0);
    SIGNAL fallings : STD_LOGIC_VECTOR(31 DOWNTO 0);
    SIGNAL levels1   : STD_LOGIC_VECTOR(31 DOWNTO 0);
    SIGNAL levels0   : STD_LOGIC_VECTOR(31 DOWNTO 0);
    SIGNAL interrupts : STD_LOGIC_VECTOR(31 DOWNTO 0);

BEGIN

    --Effective address
    --We only consider the last 8 bits of the original address. Specifically, the address[4:0] are of interest because we can distinguish each register by only considering these bits
    --Moreover, we don't have to read the bits 0 and 1 to recognize the register, then, we only need address[4:2]
    eff_addr<=address(4 DOWNTO 2);
    
    --DOUBLE SYNCHRONIZER
    PROCESS(clk)
    BEGIN
        IF rising_edge(clk) THEN
            IF rst='1' THEN
                gpio_in_sync1<=(OTHERS=>'0');
                gpio_in_sync2<=(OTHERS=>'0');
                PADIN<=(OTHERS=>'0');
            ELSE
                gpio_in_sync1<=gpio_in_async;
                gpio_in_sync2<=gpio_in_sync1;
                PADIN<=gpio_in_sync2;
            END IF; 
        END IF;
    END PROCESS;
    
    --CHANGED Juan: Now the clock is the only thing checked by the elsif and there is another inner if statement. This causes more logic levels, but ensures that any simulator/synthetizer can understand 
    --USER WRITABLE REGISTERS UPDATE
    PROCESS(clk)
    BEGIN
        IF(rising_edge(clk)) THEN
            IF rst='1' THEN
                PADDIR<=(OTHERS=>'0'); 
                PADOUT<=(OTHERS=>'0');
                PADINTEN<=(OTHERS=>'0');
                PADEN<=(OTHERS => '0');
                INTTYPE0<=(OTHERS=>'0');
                INTTYPE1<=(OTHERS=>'0');
                INTSTATUS<=(OTHERS=>'0');
                interrupt<='0';
             ELSE
                IF(read='1' AND eff_addr="111") THEN
                    --clear interupt status register
                    INTSTATUS<=(OTHERS=>'0');
                    --deassert interrupt line
                    interrupt<='0';
                --rise interrupt if there's one and if not yet pending and update status
                --ELSIF (rising_edge(clk) AND (NOT(interrupt)='1' AND (OR(interrupts)='1'))) THEN (not synthesizable by older version of Quartus)
                --ELSIF (rising_edge(clk) AND (NOT(interrupt)='1' AND interrupts/=x"00000000")) THEN CHANGED JUAN
                ELSIF(interrupts/=x"00000000") THEN --IF interrupts is not zero, it means there is at least one interrupt
                    interrupt<='1';
                    INTSTATUS<=interrupts;
                END IF;
            
                IF(write = '1') THEN
                    IF    eff_addr = "000" THEN
                        --PADDIR
                        PADDIR<=busDataIn;
                    ELSIF eff_addr = "010" THEN
                        --PADOUT
                        PADOUT<=busDataIn;
                    ELSIF eff_addr = "011" THEN
                        --PADEN
                        PADEN<=busDataIn;
                    ELSIF eff_addr = "100" THEN
                        --PADINTEN
                        PADINTEN<=busDataIn;
                    ELSIF eff_addr = "101" THEN
                        --INTTYPE0
                        INTTYPE0<=busDataIn;
                    ELSIF eff_addr = "110" THEN
                        INTTYPE1<=busDataIn;
                    ELSIF eff_addr = "111" THEN
                        INTSTATUS<=busDataIn;     
                    END IF;
                END IF;
            END IF;
        END IF;   
    END PROCESS;
    
    
    --GPIO REGISTERS READ PROCESS
    PROCESS(eff_addr, read)
    BEGIN
        IF read='1' THEN
            CASE eff_addr IS
                WHEN "000"=>
                    --PADDIR
                    busDataOut<=PADDIR;
                WHEN "001"=>
                    --PADIN
                    busDataOut<=PADIN;
                WHEN "010"=>
                    --PADOUT
                    busDataOut<=PADOUT;
                WHEN "011"=>
                    --PADEN
                    busDataOut<=PADEN;
                WHEN "100"=>
                    --PADINTEN
                    busDataOut<=PADINTEN;
                WHEN "101"=>
                    --INTTYPE0
                    busDataOut<=INTTYPE0;
                WHEN "110" =>
                    busDataOut<=INTTYPE1;
                WHEN "111"=>
                    --INTSTATUS
                    busDataOut<=INTSTATUS;
                WHEN OTHERS =>
                    busDataOut<=INTSTATUS;
            END CASE;
        ELSE
            busDataOut<=(OTHERS=>'0');
        END IF;
    END PROCESS;
    
    --INTERRUPTS
    --INTERRUPTS CAN BE ASSERTED ON: LOGICAL LEVELS OR RISING/FALLING EDGES FOR IMPULSIVE SIGNALS
    risings<=(gpio_in_sync2 AND (NOT(PADIN))) AND (NOT(INTTYPE0) AND INTTYPE1);
    fallings<=(NOT(gpio_in_sync2) AND PADIN) AND (INTTYPE0 AND INTTYPE1);
    levels1<=PADIN AND (NOT(INTTYPE0) AND (NOT(INTTYPE1)));
    levels0<=NOT(PADIN) AND (INTTYPE0 AND (NOT(INTTYPE1)));
    interrupts<= (risings OR fallings OR levels1 OR levels0) AND PADINTEN;
    
--    --CHANGED Juan: Now the clock is the thing only checked by the elsif and there is another inner if statement. This causes more logic levels, but ensures that any simulator/synthetizer can understand 
--    --UPDATE INTERRUPT STATUS REGISTER
--    --ASSERT INTERRUPT LINE
--    PROCESS(clk, rst)
--    BEGIN
--        IF rst='1' THEN
--            INTSTATUS<=(OTHERS=>'0');
--            interrupt<='0';
--        ELSIF (rising_edge(clk)) THEN
--            IF(read='1' AND eff_addr="111") THEN
--                --clear interupt status register
--                INTSTATUS<=(OTHERS=>'0');
--                --deassert interrupt line
--                interrupt<='0';
--            --rise interrupt if there's one and if not yet pending and update status
--            --ELSIF (rising_edge(clk) AND (NOT(interrupt)='1' AND (OR(interrupts)='1'))) THEN (not synthesizable by older version of Quartus)
--            --ELSIF (rising_edge(clk) AND (NOT(interrupt)='1' AND interrupts/=x"00000000")) THEN CHANGED JUAN
--            ELSIF(interrupts/=x"00000000") THEN --IF interrupts is not zero, it means there is at least one interrupt
--                interrupt<='1';
--                INTSTATUS<=interrupts;
--            END IF;
--        END IF;
--    END PROCESS;
    
    --OUTPUT SIGNALS TOGPIO PIN INTERFACE
    gpio_pad_dir<=PADDIR;
    gpio_out_sync<=PADOUT;
    
END behavior;
