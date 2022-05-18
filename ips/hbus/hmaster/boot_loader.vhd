--**************************************************************************************
--	Filename:	boot_loader.vhd
--	Project:	CNL_RISC-V
--  Version:	1.0
--	History:
--	Date:		17 May 2022
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
--	boot_loader entity, used only at startup to moove the firmware from flash to ssram
--  while this entity works, the processor will stay idle
-- **************************************************************************************
LIBRARY IEEE;
LIBRARY STD;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.NUMERIC_STD.ALL;

--using same signal names as the processor

ENTITY boot_loader IS
    GENERIC (
		busDataWidth      : INTEGER := 8;
		busAddressWidth   : INTEGER := 32;
		--4Kb instruction memory
		intrMemWidth      : INTEGER := 12
	);
    PORT (
        --system signals
        clk         : IN  STD_LOGIC;
        rst         : IN  STD_LOGIC;
        --reset event
        rst_event   : IN  STD_LOGIC;
        --(hready)
        memReady    : IN  STD_LOGIC;
        --(hread)
		memDataIn   : IN  STD_LOGIC_VECTOR(busDataWidth-1 DOWNTO 0);
		--(hwrite)
		memDataOut  : OUT STD_LOGIC_VECTOR(busDataWidth-1 DOWNTO 0);
		--(read  request)
		memRead     : OUT  STD_LOGIC;
		--(write request)
		memWrite    : OUT STD_LOGIC;
		--(haddr)
		memAddr     : OUT STD_LOGIC_VECTOR(busAddressWidth-1 DOWNTO 0);
		--status signal (='1' when boot process is still on-going)
		boot_end    : OUT STD_LOGIC
    );
END boot_loader;

ARCHITECTURE behavior OF boot_loader IS

    SIGNAL gen_address:  STD_LOGIC_VECTOR(intrMemWidth-1 DOWNTO 0);
    SIGNAL reg_wrdata:  STD_LOGIC_VECTOR(busDataWidth-1 DOWNTO 0);
    SIGNAL sel: STD_LOGIC;
    SIGNAL clear_counter: STD_LOGIC;
    SIGNAL enable_counter: STD_LOGIC;
    
    TYPE statetype IS (RST_EV_WAIT, FLASH_READ, SRAM_WRITE, BOOT_LD_END);
    SIGNAL current_state, next_state: statetype;
    
    COMPONENT counter IS
    GENERIC (
		size    : INTEGER:=16   
	); 
	PORT (
	    clk     : IN  STD_LOGIC; 
	    rst     : IN  STD_LOGIC; 
	    enable  : IN  STD_LOGIC; 
	    clear   : IN  STD_LOGIC; 
	    cOut    : OUT STD_LOGIC_VECTOR(size-1 DOWNTO 0) 
		);
    END COMPONENT;
    
BEGIN

    --Counter (address generator for flash and sram copy)
    address_generator: counter
    GENERIC MAP(
		size=>intrMemWidth   
	) 
	PORT MAP(
	    clk=>clk,
	    rst=>rst,
	    enable=>enable_counter, 
	    clear=>clear_counter,
	    cOut=>gen_address
	);
    
    --address multiplexer
    PROCESS(gen_address,sel)
    BEGIN
        IF sel='0' THEN
            --sram address, 0 extend the address generated)
            memAddr<=x"00000" & gen_address;
        ELSE
            --flash address, extend the generated address according to peripherals memory map)
            memAddr<=x"1A100" & gen_address;
        END IF;
    END PROCESS; 
    
    --copy carbon data register (holds data read from flash during sram copy)
    --sel works both as a selector (for multiplexer) and as enable
    PROCESS(clk, rst)
    BEGIN
        IF rst='1' THEN
            reg_wrdata<=(OTHERS=>'0');
        ELSIF (rising_edge(clk) and sel='1') THEN
            reg_wrdata<=memDataIn;
        END IF;
    END PROCESS;
    
    memDataOut<=reg_wrdata;
    
    --controller (RST_EV_WAIT, FLASH_READ, SRAM_WRITE, BOOT_LD_END);
    PROCESS(clk, rst)
    BEGIN
        IF rst='1' THEN
            current_state<=RST_EV_WAIT;
        ELSIF rising_edge(clk) THEN
            current_state<=next_state;
        END IF;
    END PROCESS;
    
    --memReady not used
    PROCESS(current_state, gen_address, rst_event, memReady)
    BEGIN
        CASE current_state IS
            WHEN RST_EV_WAIT=>
                memWrite<='0';
                boot_end<='0';
                memRead<='0';
                sel<='1';
                IF rst_event='1' THEN
                    --user external event happened
                    next_state<=FLASH_READ;
                    clear_counter<='1';               
                    enable_counter<='1';               
                ELSE
                    --waiting for user
                    next_state<=RST_EV_WAIT;
                    clear_counter<='0';
                    enable_counter<='0';
                END IF;
             WHEN FLASH_READ=>
                memRead<='1';
                memWrite<='0';
                boot_end<='0';
                sel<='1';
                enable_counter<='0';
                clear_counter<='0';
                next_state<=SRAM_WRITE;
             WHEN SRAM_WRITE=>
                memWrite<='1';
                boot_end<='0';
                sel<='0';
                memRead<='0';
                enable_counter<='1';
                clear_counter<='0';
                IF gen_address(intrMemWidth-1 DOWNTO 0) = x"FFF" THEN
                    next_state<=BOOT_LD_END;
                    boot_end<='1';                  
                ELSE
                    next_state<=FLASH_READ;
                END IF;
             WHEN BOOT_LD_END=>
                memRead<='0';
                memWrite<='0';
                boot_end<='1';
                sel<='0';
                enable_counter<='0';
                clear_counter<='0';
                next_state<=BOOT_LD_END;
        END CASE;
    END PROCESS;
    

END behavior;
