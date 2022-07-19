-- **************************************************************************************
--	Filename:	uart.vhd
--	Project:	CNL_RISC-V
--  Version:	1.0
--	History:
--	Date:		17 Jul 2022
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
--	uart peripheral top level entity
--
-- **************************************************************************************
LIBRARY IEEE;
LIBRARY STD;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.NUMERIC_STD.ALL;

--TODO: this uart has been designed starting from the standard UART 16550
--      some functionality are not included in this current version, for compatibility reason
--      i left the original register file so that is possible to extend this peropheral by 
--      by adding other features
--      FEATURES NOT INCLUDED: DMA, MODEM, PRESCALER DIVISION FACTOR are not currently implememnted
--      see: http://caro.su/msx/ocm_de1/16550.pdf    


ENTITY uart IS 
	PORT (
	    --system signals
		clk            : IN  STD_LOGIC;
		rst            : IN  STD_LOGIC;
		--input signals
		address        : IN  STD_LOGIC_VECTOR(2 DOWNTO 0);
		busDataIn      : IN  STD_LOGIC_VECTOR(7 DOWNTO 0);
		read           : IN  STD_LOGIC;
		write          : IN  STD_LOGIC;
		uart_rx        : IN  STD_LOGIC; --async uart RX line
		--output signals signals
		interrupt      : OUT STD_LOGIC;
		uart_tx        : OUT STD_LOGIC; --async uart TX line
		busDataOut     : OUT STD_LOGIC_VECTOR(7 DOWNTO 0)
	);
END uart;

ARCHITECTURE behavior of uart IS

    --UART RECEIVER
    COMPONENT uart_rx_core IS 
	PORT (
	    --system signals
		clk             : IN  STD_LOGIC;
		rst             : IN  STD_LOGIC;
		--input signals
		divisor         : IN  STD_LOGIC_VECTOR(15 DOWNTO 0);--divisor value for baudrate 
		parity_bit_en   : IN  STD_LOGIC;  --enable for parity bit
		parity_type     : IN  STD_LOGIC;  --even(0) or odd parity check 
		data_width      : IN  STD_LOGIC_VECTOR(1 DOWNTO 0); --data bits in the frame can be on 5,6,7,8 bits
		stop_bits       : IN  STD_LOGIC;  --number of stop bits (0 == 1 stop bit) (1 == 2 stop bits)
		error_clear     : IN  STD_LOGIC; --signals that the processor handled a bad situation
		rx_in_async     : IN  STD_LOGIC; --RX line
		--output signals signals
		break_interrupt : OUT STD_LOGIC; --break interrupt
		frame_error     : OUT STD_LOGIC; --frame error
		parity_error    : OUT STD_LOGIC; --parity error
		rx_data_buffer  : OUT STD_LOGIC_VECTOR(7 DOWNTO 0); --registered data
		rx_valid        : OUT STD_LOGIC --data correctly sampled
	);
    END COMPONENT;
    
    
    --UART TRANSMITTER
    COMPONENT uart_tx_core IS 
	PORT (
	    --system signals
		clk             : IN  STD_LOGIC;
		rst             : IN  STD_LOGIC;
		--input signals
		divisor         : IN  STD_LOGIC_VECTOR(15 DOWNTO 0);--divisor value for baudrate
		parity_bit_en   : IN  STD_LOGIC;  --enable for parity bit
		parity_type     : IN  STD_LOGIC;  --even(0) or odd parity check 
		data_width      : IN  STD_LOGIC_VECTOR(1 DOWNTO 0); --data bits in the frame can be on 5,6,7,8 bits
		stop_bits       : IN  STD_LOGIC;  --number of stop bits (0 == 1 stop bit) (1 == 2 stop bits)
		tx_data_i       : IN  STD_LOGIC_VECTOR(7 DOWNTO 0); --data to be transmitted
		tx_valid        : IN  STD_LOGIC; --some data is ready to be transmitted
		--output signals signals
		tx_ready        : OUT STD_LOGIC; --transmitter ready for next data
		tx_out          : OUT STD_LOGIC --TX line
	);
    END COMPONENT;
    
    
    --UART INTERRUPT CONTROLLER
    COMPONENT uart_interrupt IS 
    GENERIC (
        FIFO_DEPTH   : INTEGER:=16;
        LOG_FIFO_D   : INTEGER:=4
    );
	PORT (
	    --system signals
		clk                 : IN  STD_LOGIC;
		rst                 : IN  STD_LOGIC;
		--input signals
		IER                 : IN  STD_LOGIC_VECTOR(2 DOWNTO 0); --Interrupt Enable Register: RLS, THRe, DR enables
		rx_fifo_trigger_lv  : IN  STD_LOGIC_VECTOR(1 DOWNTO 0); --Receiver fifo trigger level
		rx_elements         : IN  STD_LOGIC_VECTOR(LOG_FIFO_D DOWNTO 0); --#elements in rx fifo
		tx_elements         : IN  STD_LOGIC_VECTOR(LOG_FIFO_D DOWNTO 0); --#elements in tx fifo
		rx_line_error       : IN  STD_LOGIC; --Parity error or Break error or Overrun error or frame error in rx line
		interrupt_clear     : IN  STD_LOGIC; --bit used to clear interrup line
		rx_data_ready       : IN  STD_LOGIC; --new data received
		char_timeout        : IN  STD_LOGIC; --no data has been received and no data has been read from receiver fifo during a certain time
		--output signals signals
		interrupt           : OUT STD_LOGIC;
		interrupt_isr_code  : OUT STD_LOGIC_VECTOR(3 DOWNTO 0) --id of the interrupt raised
	);
    END COMPONENT;
    
    
    --UART GENERIC FIFO
    COMPONENT fifo IS 
    GENERIC (
        DATA_WIDTH:  INTEGER:=32;
        FIFO_DEPTH:  INTEGER:=16;
        LOG_FIFO_D:  INTEGER:=4
    );
	PORT (
	    --system signals
		clk             : IN  STD_LOGIC;
		rst             : IN  STD_LOGIC;
		--input signals
		clear           : IN  STD_LOGIC;    --clear the FIFO
		data_in         : IN  STD_LOGIC_VECTOR(DATA_WIDTH-1 DOWNTO 0); --data IN
		read_request    : IN  STD_LOGIC;  --read operation reequest on the FIFO
		write_request   : IN  STD_LOGIC;  --write operation reequest on the FIFO
		--output signals signals
		elements        : OUT STD_LOGIC_VECTOR(LOG_FIFO_D DOWNTO 0);  --#elements in the queue
		data_out        : OUT STD_LOGIC_VECTOR(DATA_WIDTH-1 DOWNTO 0);  --data OUT
		fifo_empty      : OUT STD_LOGIC; --is fifo empty?
		fifo_full       : OUT STD_LOGIC --is fifo full
	);
    END COMPONENT;

    --Register File addresses encoding
    CONSTANT RHR: INTEGER:=0;   --VIRTUAL REGISTER (NOT PHYSICALLY IN THE REGISER FILE)
    CONSTANT THR: INTEGER:=0;   --VIRTUAL REGISTER (NOT PHYSICALLY IN THE REGISER FILE)
    CONSTANT IER: INTEGER:=1;
    CONSTANT ISR: INTEGER:=2;   --VIRTUAL REGISTER (..)
    CONSTANT FCR: INTEGER:=2;
    CONSTANT LCR: INTEGER:=3;
    CONSTANT MCR: INTEGER:=4;   --UNUSED
    CONSTANT LSR: INTEGER:=5;
    CONSTANT MSR: INTEGER:=6;   --UNUSED
    CONSTANT SPR: INTEGER:=7;   --UNUSED
    CONSTANT DLL: INTEGER:=0;
    CONSTANT DLM: INTEGER:=1;
    CONSTANT PSD: INTEGER:=5;   --NOT IMPLEMENTED
    
    --FIFOs CONFIGURATION
    CONSTANT DATA_WIDTH: INTEGER:= 8;
    CONSTANT FIFO_DEPTH: INTEGER:=16;
    CONSTANT LOG_FIFO_D: INTEGER:=4;
    CONSTANT DATA_ERRORS: INTEGER:=3; --(parity + framing + break are saved foreach received frame)

    --Register File
    --TODO: inefficient! registers should be separated..
    TYPE UART_REG_FILE IS ARRAY (0 TO 9) OF STD_LOGIC_VECTOR(7 DOWNTO 0);
    SIGNAL current_regfile, next_regfile: UART_REG_FILE;
    
    --Receiver signals (some of them are coming from the FIFO)
    SIGNAL rx_fifo_empty: STD_LOGIC;
    SIGNAL rx_parity_error: STD_LOGIC;
    SIGNAL rx_overrun_error_clear: STD_LOGIC;
    SIGNAL rx_framing_error: STD_LOGIC;
    SIGNAL rx_break_interrupt: STD_LOGIC;
    SIGNAL rx_fifo_full: STD_LOGIC;
    SIGNAL rx_elements: STD_LOGIC_VECTOR(LOG_FIFO_D DOWNTO 0);
    SIGNAL rx_data_i: STD_LOGIC_VECTOR(7 DOWNTO 0);
    SIGNAL rx_read_request: STD_LOGIC;
    SIGNAL rx_finished: STD_LOGIC;
    SIGNAL rx_frame: STD_LOGIC_VECTOR(DATA_WIDTH + DATA_ERRORS -1 DOWNTO 0); --entire receiver frame is saved into FIFO to be analyzed by the interrupt controller when data is read from FIFO
    SIGNAL rx_fifo_data_out: STD_LOGIC_VECTOR(DATA_WIDTH + DATA_ERRORS -1 DOWNTO 0);
    SIGNAL rx_line_error: STD_LOGIC;  
    
    --TODO
    SIGNAL rx_fifo_error: STD_LOGIC;
    SIGNAL rx_char_timeout: STD_LOGIC; --single baudrate generator should be used
    
    --Transmitter signals (some of them are coming from the FIFO)
    SIGNAL tx_fifo_empty: STD_LOGIC;
    SIGNAL tx_elements: STD_LOGIC_VECTOR(LOG_FIFO_D DOWNTO 0);
    SIGNAL tx_fifo_full: STD_LOGIC;
    SIGNAL tx_ready: STD_LOGIC;
    SIGNAL tx_write_request: STD_LOGIC;
    SIGNAL tx_fifo_data_out: STD_LOGIC_VECTOR(7 DOWNTO 0);
    
    --Interrupt signals
    --TODO check interrupt clearing correctness
    SIGNAL clear_int: STD_LOGIC;
    SIGNAL clear_thr: STD_LOGIC;
    SIGNAL ISR_code: STD_LOGIC_VECTOR(3 DOWNTO 0);
    
    --Divisor (DLL + DLM)
    SIGNAL divisor: STD_LOGIC_VECTOR(15 DOWNTO 0);
     

BEGIN

    --DIVISOR (DLL + DLM)
    divisor<=current_regfile(DLM+8) & current_regfile(DLL+8);

    --RECEIVER
    U_RX: uart_rx_core  
	PORT MAP(
		clk=>clk,
		rst=>rst,
		divisor=>divisor,
		parity_bit_en=>current_regfile(LCR)(3),
		parity_type=>current_regfile(LCR)(4), 
		data_width=>current_regfile(LCR)(1 DOWNTO 0),
		stop_bits=>current_regfile(LCR)(2),
		error_clear=>'0',
		rx_in_async=>uart_rx,
		break_interrupt=>rx_break_interrupt,
		frame_error=>rx_framing_error,
		parity_error=>rx_parity_error,
		rx_data_buffer=>rx_data_i,
		rx_valid=>rx_finished
	);
	
	--Receiver frame as a concatenation (ERRORS + DATA)
	rx_frame<=rx_break_interrupt & rx_framing_error & rx_parity_error & rx_data_i;
	
	--RECEIVER FIFO
	U_RX_FIFO: fifo 
    GENERIC MAP(
        DATA_WIDTH=>DATA_WIDTH+DATA_ERRORS,
        FIFO_DEPTH=>FIFO_DEPTH,
        LOG_FIFO_D=>LOG_FIFO_D
    )
	PORT MAP(
		clk=>clk,
		rst=>rst,
		clear=>current_regfile(FCR)(1),
		data_in=>rx_frame,
		read_request=>rx_read_request,
		write_request=>rx_finished,
		elements=>rx_elements,
		data_out=>rx_fifo_data_out,
		fifo_empty=>rx_fifo_empty,
		fifo_full=>rx_fifo_full
	);
	
	--Receiver Line Error (used by interrupt controller)
	rx_line_error<=rx_fifo_data_out(10) OR rx_fifo_data_out(9) OR rx_fifo_data_out(8);
	
	--TRANSMITTER
	U_TX: uart_tx_core 
	PORT MAP(
		clk=>clk,
		rst=>rst,
		divisor=>divisor,
		parity_bit_en=>current_regfile(LCR)(3),
		parity_type=>current_regfile(LCR)(4),
		data_width=>current_regfile(LCR)(1 DOWNTO 0),
		stop_bits=>current_regfile(LCR)(2),
		tx_data_i=>tx_fifo_data_out,
		tx_valid=>NOT(tx_fifo_empty),
		tx_ready=>tx_ready,
		tx_out=>uart_tx
	);
	
	--TRANSMITTER FIFO
	U_TX_FIFO: fifo 
    GENERIC MAP(
        DATA_WIDTH=>DATA_WIDTH,
        FIFO_DEPTH=>FIFO_DEPTH,
        LOG_FIFO_D=>LOG_FIFO_D
    )
	PORT MAP(
		clk=>clk,
		rst=>rst,
		clear=>current_regfile(FCR)(2),
		data_in=>busDataIn,
		read_request=>tx_ready,
		write_request=>tx_write_request,
		elements=>tx_elements,
		data_out=>tx_fifo_data_out,
		fifo_empty=>tx_fifo_empty,
		fifo_full=>tx_fifo_full
	);
	
	--INTERRUPT CONTROLLER
	U_IN_CTRL: uart_interrupt 
    GENERIC MAP(
        FIFO_DEPTH=>FIFO_DEPTH,
        LOG_FIFO_D=>LOG_FIFO_D
    )
	PORT MAP(
		clk=>clk,
		rst=>rst,
		IER=>current_regfile(IER)(2 DOWNTO 0),
		rx_fifo_trigger_lv=>current_regfile(FCR)(7 DOWNTO 6),
		rx_elements=>rx_elements,
		tx_elements=>tx_elements,
		rx_line_error=>rx_line_error,
		interrupt_clear=>(clear_int OR clear_thr),
		rx_data_ready=>NOT(rx_fifo_empty),
		char_timeout=>'0',
		interrupt=> interrupt,
		interrupt_isr_code=>ISR_code
	);

    --Register write combinatorial update logic
    PROCESS(ALL)
    BEGIN
        next_regfile<=current_regfile;     
        next_regfile(LSR)(0)<=NOT(rx_fifo_empty); --LSR's Data Ready
        --overrun error update --TODO: overrun is different if fifo is disabled
        IF rx_overrun_error_clear='1' THEN
            next_regfile(LSR)(1)<='0';
        ELSIF (rx_fifo_full='1' AND rx_finished='1') THEN
            next_regfile(LSR)(1)<='1';
        END IF;
        next_regfile(LSR)(2)<=rx_fifo_data_out(8); --LSR's parity error
        next_regfile(LSR)(3)<=rx_fifo_data_out(9); --LSR's framing error
        next_regfile(LSR)(4)<=rx_fifo_data_out(10); --LSR's break error
        next_regfile(LSR)(5)<=tx_fifo_empty; --LSR's transmitter fifo empty
        next_regfile(LSR)(6)<=tx_ready AND tx_fifo_empty; --LSR's transmitter ready to send and fifo empty
        next_regfile(LSR)(7)<=rx_fifo_error; --LSR's fifo data error
        tx_write_request<='0';
        clear_thr<='0';
        IF write='1' THEN
            CASE TO_INTEGER(UNSIGNED(address)) IS
                WHEN THR  => --THR OR DLL
                    IF current_regfile(LCR)(7) = '1' THEN
                        --we want to write to DLL register
                        next_regfile(DLL + 8)<=busDataIn;
                    ELSE
                        --we want to write to THR register (write to tx FIFO)
                        tx_write_request<='1'; 
                        --clear THR interrupt if pending
                        IF ISR_code="0010" THEN
                            clear_thr<='1';
                        END IF;
                    END IF;
                
                WHEN IER => --IER OR DLM
                    IF current_regfile(LCR)(7) = '1' THEN
                        --we want to write to DLM register
                        next_regfile(DLM + 8)<=busDataIn;
                    ELSE
                        --we want to write to IER register
                        next_regfile(IER)<=busDataIn;
                    END IF;
                    
                WHEN FCR =>
                    next_regfile(FCR)(1)<=busDataIn(1);
                    next_regfile(FCR)(2)<=busDataIn(2);
                    next_regfile(FCR)(6)<=busDataIn(6);
                    next_regfile(FCR)(7)<=busDataIn(7);
                
                WHEN LCR =>
                    next_regfile(LCR)<=busDataIn;
                
                WHEN OTHERS => NULL;
            END CASE;
        END IF;
    END PROCESS;

    --Register write sequential update
    PROCESS(clk, rst)
    BEGIN
        IF rst='1' THEN
            current_regfile(IER)<=(OTHERS=>'0');
            current_regfile(ISR)<=X"01";
            current_regfile(FCR)<=(OTHERS=>'0');
            current_regfile(LCR)<=(OTHERS=>'0');
            current_regfile(MCR)<=(OTHERS=>'0');
            current_regfile(LSR)<=X"60";
            current_regfile(DLL+8)<=X"01";
            current_regfile(DLM+8)<=X"01";
        ELSIF rising_edge(clk) THEN
            current_regfile<=next_regfile;
        END IF;
    END PROCESS;
    
    --Register Read logic
    PROCESS(ALL)
    BEGIN
        busDataOut<=rx_data_i;
        clear_int<='0';
        rx_read_request<='0';
        rx_overrun_error_clear<='0';
        IF read='1' THEN
            CASE TO_INTEGER(UNSIGNED(address)) IS
                WHEN RHR => --RHR or DLL
                    IF current_regfile(LCR)(7) = '1' THEN
                        --we want to read the DLL register
                        busDataOut<=current_regfile(DLL+8);
                    ELSE
                        --we want to read the THR register (read the tx FIFO)
                        rx_read_request<='1'; 
                        --clear RDReady interrupt if pending
                        IF ISR_code="0100" THEN
                            clear_int<='1';
                        END IF;
                        busDataOut<=rx_data_i;
                    END IF;
                    
                WHEN IER => --IER OR DLM
                    IF current_regfile(LCR)(7) = '1' THEN
                        --we want to read the DLM register
                        busDataOut<=current_regfile(DLM+8);
                    ELSE
                        --we want to read the IER register
                        busDataOut<=current_regfile(IER);
                        
                    END IF;
                    
                WHEN ISR =>
                    --ISR is virtual, (just the IID code from the Interrupt controller is used)
                    busDataOut<="0000" & ISR_code;
                    --clear THR Empty interrupt if pending
                    IF ISR_code="0010" THEN
                        clear_int<='1';
                    END IF;
                    
                WHEN LCR =>
                    busDataOut<=current_regfile(LCR);
                    
                WHEN LSR =>
                    busDataOut<=current_regfile(LSR);
                    rx_overrun_error_clear<='1';
                    --clear the RLS interrupt if active
                    IF ISR_code="0110" THEN
                        clear_int<='1';
                    END IF;
                    
                WHEN OTHERS => NULL;
                    
            END CASE;
        END IF;
    END PROCESS;

END behavior;
