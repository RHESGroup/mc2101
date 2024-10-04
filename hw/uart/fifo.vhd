-- **************************************************************************************
--	Filename:	fifo.vhd
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
--	FIFO data structure
--
-- **************************************************************************************

LIBRARY IEEE;
LIBRARY STD;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.NUMERIC_STD.ALL;
USE work.CONSTANTS.ALL;

ENTITY fifo IS 
    GENERIC(
        DATA_WIDTHFIFO : INTEGER;
        FIFO_DEPTH : INTEGER;
        LOG_FIFO_D : INTEGER
    );
	PORT ( 
	    --system signals
		clk             : IN  STD_LOGIC;
		rst             : IN  STD_LOGIC;
		--input signals
		clear           : IN  STD_LOGIC;    --clear the FIFO
		data_in         : IN  STD_LOGIC_VECTOR(DATA_WIDTHFIFO-1 DOWNTO 0); --data IN
		read_request    : IN  STD_LOGIC;  --read operation reequest on the FIFO
		write_request   : IN  STD_LOGIC;  --write operation reequest on the FIFO
		--output signals 
		elements        : OUT STD_LOGIC_VECTOR(LOG_FIFO_D DOWNTO 0);  --#elements in the queue
		data_out        : OUT STD_LOGIC_VECTOR(DATA_WIDTHFIFO-1 DOWNTO 0);  --data OUT
		fifo_empty      : OUT STD_LOGIC; --is fifo empty?
		fifo_full       : OUT STD_LOGIC --is fifo full
	);
END fifo;


ARCHITECTURE behavior OF fifo IS
    --FIFO DATA TYPE
    SUBTYPE WORD IS STD_LOGIC_VECTOR(DATA_WIDTHFIFO-1 DOWNTO 0);
    TYPE STORAGE IS ARRAY(FIFO_DEPTH-1 DOWNTO 0) OF WORD;
    SIGNAL QUEUE: STORAGE;
    
    --Counter of #elements in the queue
    SIGNAL elements_counter: UNSIGNED(LOG_FIFO_D DOWNTO 0); --Helps to keep track of the available slots
    
    --Pointer to the last data IN written 
    SIGNAL pointer_in: UNSIGNED(LOG_FIFO_D-1 DOWNTO 0);
    
    --Pointer to the last data OUT read
    SIGNAL pointer_out: UNSIGNED(LOG_FIFO_D-1 DOWNTO 0);
    
    --empty fifo
    SIGNAL empty: STD_LOGIC;
    
    --full fifo
    SIGNAL full: STD_LOGIC;

BEGIN
    
    full<='1' WHEN TO_INTEGER(elements_counter)=FIFO_DEPTH ELSE '0'; -- '1' if we are at the bottom of the fifo
    empty<='1' WHEN TO_INTEGER(elements_counter)=0 ELSE '0'; -- '1' if we are at the top of the fifo
    elements<=STD_LOGIC_VECTOR(elements_counter);
    
    
    fifo_empty<=empty;
    fifo_full<=full;
    
    --update elements_counter based on the operation issued on the FIFO
    PROCESS(clk, rst)
    BEGIN
        IF (rst='1' OR clear='1') THEN 
            elements_counter<=(OTHERS=>'0');
        ELSIF rising_edge(clk) THEN
            --decrease the counter only if there's a read operation and the fifo is not empty
            --at the same time check that there is not a write operation occuring
            --write operation is valid only if the fifo is not full
            IF (read_request='1' AND empty='0' AND (write_request='0' OR full='1')) THEN
                elements_counter<=elements_counter-1;
            --increase the counter if there is not a valid read operation 
            --and also check that there is a valid write operation
            ELSIF ((read_request='0' OR empty='1') AND write_request='1' AND full='0') THEN
                elements_counter<=elements_counter+1;
            END IF;
        END IF;    
    END PROCESS;
    
    
    --Update FIFO memory
    PROCESS(clk, rst)
    BEGIN
        IF (rst='1' OR clear='1') THEN
            QUEUE<=(OTHERS=>(OTHERS=>'0'));
        ELSIF rising_edge(clk) THEN
            --update on valid write operation
            IF (write_request='1' AND full='0') THEN --If we want to write and the buffer is not full
                QUEUE(TO_INTEGER(pointer_in))<=data_in;
            END IF;
        END IF;
    END PROCESS;
    
    --Update read and write pointers (ENQUEUE, DEQUEUE)
    PROCESS(clk, rst)
    BEGIN
        IF (rst='1' OR clear='1') THEN
            pointer_in<=(OTHERS=>'0');
            pointer_out<=(OTHERS=>'0');
        ELSIF rising_edge(clk) THEN
            --update pointer_in on valid write operation
            IF (write_request='1' AND full='0') THEN --If we want to write and the buffer is not full
                IF (to_integer(pointer_in) = (FIFO_DEPTH-1)) THEN --If we are in the last slot of the queue...
                    pointer_in<=(OTHERS=>'0');  --Go back and point to the beginning of the buffer
                ELSE --If we still have more available slots
                    pointer_in<=pointer_in+1;
                END IF;
            END IF;
            --update pointer_out on valid read operation
            IF (read_request='1' AND empty='0') THEN --If we want to read and the buffer is not empty
                IF (to_integer(pointer_out) = (FIFO_DEPTH-1)) THEN --If we are in the last slot of the queue...
                    pointer_out<=(OTHERS=>'0'); --Go back and point to the beginning of the buffer
                ELSE --If we still have more available slots
                    pointer_out<=pointer_out+1;
                END IF;
            END IF;                
        END IF;
    END PROCESS;

    data_out<=QUEUE(TO_INTEGER(pointer_out)); ---Pointer out points to the first data received

END behavior;
