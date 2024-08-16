-- **************************************************************************************
--	Filename:	gpio_pads_if.vhd
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
--	gpio pads interface: interface to bidirectional bus connected to physical pins
--
-- **************************************************************************************
LIBRARY IEEE;
LIBRARY STD;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.NUMERIC_STD.ALL;

ENTITY gpio_pad IS   
	PORT (
	    --INPUTS
	    clk:           IN STD_LOGIC;
	    rst:           IN STD_LOGIC;
	    gpio_dir : IN STD_LOGIC;
	    gpio_port_out: IN STD_LOGIC;
	    gpio_en      : IN STD_LOGIC;
	    --OUTPUTS
	    gpio_port_in : OUT STD_LOGIC;
	    --INOUTS
	    gpio_pin:  INOUT STD_LOGIC
	);
END gpio_pad;

ARCHITECTURE behavior OF gpio_pad IS

TYPE state IS(TRISTATE, INPUT, OUTPUT);
SIGNAL next_state, current_state : state;
--SIGNAL current_gpio_port_in, next_gpio_port_in : STD_LOGIC;
SIGNAL current_gpio_pin, next_gpio_pin : STD_LOGIC;

BEGIN


    Clock: PROCESS(clk, rst)
    BEGIN
        IF rst = '1' THEN
            current_state<=TRISTATE;
            current_gpio_pin <= 'Z'; 
            --current_gpio_port_in <= 'Z';   
        ELSIF(rising_edge(clk)) THEN
           current_state <= next_state;  
           current_gpio_pin <= next_gpio_pin;
        END IF; 
    END PROCESS; 

    PROCESS(gpio_dir, gpio_port_out, gpio_pin, gpio_en, current_state, current_gpio_pin)
    BEGIN
        next_gpio_pin <= current_gpio_pin;
        
        CASE(current_state) IS
        
            WHEN TRISTATE=>
            
                next_gpio_pin <= 'Z';
                
                IF gpio_en = '1' AND gpio_dir ='0' THEN
                    next_state <= INPUT;
                    next_gpio_pin <= gpio_pin;
                ELSIF gpio_en = '1' AND gpio_dir = '1' THEN
                    next_state <= OUTPUT;
                    next_gpio_pin <= gpio_port_out;
                ELSE
                    next_state <= TRISTATE;
                END IF;
                
            WHEN INPUT=>
            
                next_gpio_pin <= gpio_pin;
            
                
                IF gpio_en = '1' AND gpio_dir ='0' THEN
                    next_state <= INPUT;
                    next_gpio_pin <= gpio_pin;
                ELSIF gpio_en = '1' AND gpio_dir = '1' THEN
                    next_state <= OUTPUT;
                    next_gpio_pin <= gpio_port_out;
                ELSE 
                    next_state <= TRISTATE;
                    next_gpio_pin <= 'Z';
                END IF; 
                
            WHEN OUTPUT=>
                
                next_gpio_pin <= gpio_port_out;
                
                IF gpio_en = '1' AND gpio_dir ='0' THEN
                    next_state <= INPUT;
                    next_gpio_pin <= gpio_pin;
                ELSIF gpio_en = '1' AND gpio_dir = '1' THEN
                    next_state <= OUTPUT;
                    next_gpio_pin <= gpio_port_out;
                ELSE 
                    next_state <= TRISTATE;
                    next_gpio_pin <= 'Z';
                END IF; 
                
            WHEN OTHERS =>
                next_state <= TRISTATE;
                next_gpio_pin <= 'Z';
        
        END CASE;
        
        gpio_port_in <= current_gpio_pin;
        gpio_pin <= current_gpio_pin;

    END PROCESS;
    
END behavior;
