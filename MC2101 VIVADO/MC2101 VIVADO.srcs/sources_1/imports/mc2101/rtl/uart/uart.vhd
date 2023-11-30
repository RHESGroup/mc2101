-- **************************************************************************************
--	Filename:	uart.vhd
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
--	uart peripheral top level entity
--
-- **************************************************************************************
LIBRARY IEEE;
LIBRARY STD;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.NUMERIC_STD.ALL;

--TODO: this uart has been designed starting from the standard UART 16550
--      some functionality are not included in this current version
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
    
    --FIFOs CONFIGURATION
    CONSTANT DATA_WIDTH: INTEGER:= 8;
    CONSTANT FIFO_DEPTH: INTEGER:=16;
    CONSTANT LOG_FIFO_D: INTEGER:=4;
    CONSTANT DATA_ERRORS: INTEGER:=3; --(parity + framing + break are saved foreach received frame)

    --Register file signals
    --Interrupt enable register
    SIGNAL reg_IER: STD_LOGIC_VECTOR(2 DOWNTO 0);
    SIGNAL read_IER: STD_LOGIC;
    SIGNAL write_IER: STD_LOGIC;
    
    --Fifo control register
    SIGNAL reg_FCR: STD_LOGIC_VECTOR(3 DOWNTO 0);
    SIGNAL write_FCR: STD_LOGIC;
    
    --Line control register
    SIGNAL reg_LCR: STD_LOGIC_VECTOR(4 DOWNTO 0);
    SIGNAL read_LCR: STD_LOGIC;
    SIGNAL write_LCR: STD_LOGIC;
    
    --Line status register
    SIGNAL reg_LSR: STD_LOGIC_VECTOR(6 DOWNTO 0);
    SIGNAL read_LSR: STD_LOGIC;
    
    --Divisor lsb
    SIGNAL reg_DLL: STD_LOGIC_VECTOR(7 DOWNTO 0);
    SIGNAL read_DLL: STD_LOGIC;
    SIGNAL write_DLL: STD_LOGIC;
    
    --Divisor msb
    SIGNAL reg_DLM: STD_LOGIC_VECTOR(7 DOWNTO 0);
    SIGNAL read_DLM: STD_LOGIC;
    SIGNAL write_DLM: STD_LOGIC;
    
    --Transmitter holding register
    SIGNAL write_THR: STD_LOGIC;
    
    --Receiver holding register
    SIGNAL read_RHR: STD_LOGIC;
    
    --Interrupt status register
    SIGNAL read_ISR: STD_LOGIC;
    
    --Divisor (DLL + DLM)
    SIGNAL divisor: STD_LOGIC_VECTOR(15 DOWNTO 0);
    
    --Receiver signals
    SIGNAL rx_parity_error: STD_LOGIC;
    SIGNAL rx_framing_error: STD_LOGIC;
    SIGNAL rx_break_interrupt: STD_LOGIC;
    SIGNAL rx_data_i: STD_LOGIC_VECTOR(7 DOWNTO 0);
    SIGNAL rx_frame: STD_LOGIC_VECTOR(DATA_WIDTH + DATA_ERRORS -1 DOWNTO 0); --entire receiver frame is saved into FIFO to be analyzed by the interrupt controller when data is read from FIFO
    SIGNAL rx_finished: STD_LOGIC;
    SIGNAL rx_elements: STD_LOGIC_VECTOR(LOG_FIFO_D DOWNTO 0);
	SIGNAL rx_fifo_data_out: STD_LOGIC_VECTOR(DATA_WIDTH + DATA_ERRORS -1 DOWNTO 0);
	SIGNAL rx_fifo_empty: STD_LOGIC;
	SIGNAL rx_fifo_full: STD_LOGIC;
	SIGNAL rx_line_error: STD_LOGIC;
    
    --Transmitter signals
    SIGNAL tx_fifo_data_out: STD_LOGIC_VECTOR(7 DOWNTO 0);
    SIGNAL tx_fifo_empty: STD_LOGIC;
    SIGNAL tx_ready: STD_LOGIC;
    SIGNAL tx_elements: STD_LOGIC_VECTOR(LOG_FIFO_D DOWNTO 0);
    SIGNAL tx_fifo_full : STD_LOGIC;
    
    --Timeout counters
    SIGNAL baud_counter: UNSIGNED(15 DOWNTO 0);
    SIGNAL timeout_counter: UNSIGNED(5 DOWNTO 0);
    SIGNAL rx_char_timeout: STD_LOGIC;
    SIGNAL clear_cnt: STD_LOGIC;
    
    --Interrupt signals
    SIGNAL clear_int: STD_LOGIC;
    SIGNAL ISR_code: STD_LOGIC_VECTOR(3 DOWNTO 0);

BEGIN

    --RECEIVER
    U_RX: uart_rx_core  
	PORT MAP(
		clk=>clk,
		rst=>rst,
		divisor=>divisor,
		parity_bit_en=>reg_LCR(3),
		parity_type=>reg_LCR(4), 
		data_width=>reg_LCR(1 DOWNTO 0),
		stop_bits=>reg_LCR(2),
		rx_in_async=>uart_rx,
		break_interrupt=>rx_break_interrupt,
		frame_error=>rx_framing_error,
		parity_error=>rx_parity_error,
		rx_data_buffer=>rx_data_i,
		rx_valid=>rx_finished
	);
	
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
		clear=>reg_FCR(0),
		data_in=>rx_frame,
		read_request=>read_RHR,
		write_request=>rx_finished,
		elements=>rx_elements,
		data_out=>rx_fifo_data_out,
		fifo_empty=>rx_fifo_empty,
		fifo_full=>rx_fifo_full
	);
	
	--TRANSMITTER
	U_TX: uart_tx_core 
	PORT MAP(
		clk=>clk,
		rst=>rst,
		divisor=>divisor,
		parity_bit_en=>reg_LCR(3),
		parity_type=>reg_LCR(4),
		data_width=>reg_LCR(1 DOWNTO 0),
		stop_bits=>reg_LCR(2),
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
		clear=>reg_FCR(1),
		data_in=>busDataIn,
		read_request=>tx_ready,
		write_request=>write_THR,
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
		IER=>reg_IER(2 DOWNTO 0),
		rx_fifo_trigger_lv=>reg_FCR(3 DOWNTO 2),
		rx_elements=>rx_elements,
		tx_elements=>tx_elements,
		rx_line_error=>rx_line_error,
		interrupt_clear=>clear_int,
		char_timeout=>rx_char_timeout,
		interrupt=>interrupt,
		interrupt_isr_code=>ISR_code
	);

    --DIVISOR (DLL + DLM)
    divisor<=reg_DLM & reg_DLL;
    
    --Receiver Line Error (used by interrupt controller) (Overrun error included)
	rx_line_error<=rx_fifo_data_out(10) OR 
	               rx_fifo_data_out(9)  OR 
	               rx_fifo_data_out(8)  OR 
	               reg_LSR(1);
    
    --Receiver frame as a concatenation (ERRORS + DATA)
	rx_frame<=rx_break_interrupt & rx_framing_error & rx_parity_error & rx_data_i;
    
    --IER register 
    read_IER<='1' WHEN read='1' AND address="000" ELSE '0';
    write_IER<='1' WHEN write='1' AND address="000" ELSE '0';
    
    PROCESS(clk, rst)
    BEGIN
        IF rst='1' THEN
            reg_IER<=(OTHERS=>'0');
        ELSIF rising_edge(clk) THEN
            IF write_IER='1' THEN
                reg_IER<=busDataIn(2 DOWNTO 0);
            END IF;
        END IF;
    END PROCESS;
    
    --FCR register 
    write_FCR<='1' WHEN write='1' AND address="010" ELSE '0';
    
    PROCESS(clk, rst)
    BEGIN
        IF rst='1' THEN
            reg_FCR<=(OTHERS=>'0');
        ELSIF rising_edge(clk) THEN
            IF write_FCR='1' THEN
                reg_FCR<=busDataIn(3 DOWNTO 0);
            END IF;
        END IF;
    END PROCESS;
    
    --LCR register
    read_LCR<='1' WHEN read='1' AND address="011" ELSE '0';
    write_LCR<='1' WHEN write='1' AND address="011" ELSE '0';
    
    PROCESS(clk, rst)
    BEGIN
        IF rst='1' THEN
            reg_LCR<=(OTHERS=>'0');
        ELSIF rising_edge(clk) THEN
            IF write_LCR='1' THEN
                reg_LCR<=busDataIn(4 DOWNTO 0);
            END IF;
        END IF;
    END PROCESS;
    
    --LSR register
    read_LSR<='1' WHEN read='1' AND address="100" ELSE '0';
    
    PROCESS(clk, rst)
    BEGIN
        IF rst='1' THEN
            reg_LSR<="1100000";
        ELSIF rising_edge(clk) THEN
            --LSR's Data Ready
            reg_LSR(0)<=NOT(rx_fifo_empty); 
            --LSR's overrun error
            IF read_LSR='1' THEN
                reg_LSR(1)<='0';
            ELSIF (rx_fifo_full='1' AND rx_finished='1') THEN
                reg_LSR(1)<='1';
            END IF;
            --LSR's parity error
            reg_LSR(2)<=rx_fifo_data_out(8);
            --LSR's framing error
            reg_LSR(3)<=rx_fifo_data_out(9);
            --LSR's break error
            reg_LSR(4)<=rx_fifo_data_out(10);
            --LSR's transmitter fifo empty
            reg_LSR(5)<=tx_fifo_empty;
            --LSR's transmitter ready to send and fifo empty
            reg_LSR(6)<=tx_ready AND tx_fifo_empty;    
        END IF; 
    END PROCESS;
    
    --DLL register 
    read_DLL<='1' WHEN read='1' AND address="101" ELSE '0';
    write_DLL<='1' WHEN write='1' AND address="101" ELSE '0';
    
    PROCESS(clk, rst)
    BEGIN
        IF rst='1' THEN
            reg_DLL<=X"01";
        ELSIF rising_edge(clk) THEN
            IF write_DLL='1' THEN
                reg_DLL<=busDataIn(7 DOWNTO 0);
            END IF;
        END IF;
    END PROCESS;
    
    --DLM register 
    read_DLM<='1' WHEN read='1' AND address="110" ELSE '0';
    write_DLM<='1' WHEN write='1' AND address="110" ELSE '0';
    
    PROCESS(clk, rst)
    BEGIN
        IF rst='1' THEN
            reg_DLM<=X"01";
        ELSIF rising_edge(clk) THEN
            IF write_DLM='1' THEN
                reg_DLM<=busDataIn(7 DOWNTO 0);
            END IF;
        END IF;
    END PROCESS;
    
    --THR register
    write_THR<='1' WHEN write='1' AND address="111" ELSE '0';
    
    --RHR register
    read_RHR<='1' WHEN read='1' AND address="111" ELSE '0';
    
    --ISR register
    read_ISR<='1' WHEN read='1' AND address="001" ELSE '0';
    
    --busDataOut update 
    busDataOut<="00000" & reg_IER WHEN read_IER='1' ELSE
                "0000" & ISR_code WHEN read_ISR='1' ELSE
                "000" & reg_LCR WHEN read_LCR='1' ELSE
                '0' & reg_LSR WHEN read_LSR='1' ELSE
                reg_DLL WHEN read_DLL='1' ELSE
                reg_DLM WHEN read_DLM='1' ELSE
                rx_data_i;
                
    --Interrupt clear process
    clear_int<='1' WHEN ISR_code="0110" AND read_LSR='1' ELSE
               '1' WHEN ISR_code="0100" AND read_RHR='1' ELSE
               '1' WHEN ISR_code="1100" AND read_RHR='1' ELSE
               '1' WHEN ISR_code="0010" AND (write_THR='1' OR read_ISR='1') ELSE
               '0';
                
    --Receiver transmission timeout
    PROCESS(clk, rst)
    BEGIN
        IF rst='1' THEN
            baud_counter<=(OTHERS=>'0');
        ELSIF rising_edge(clk) THEN
            IF clear_cnt='1' THEN
                baud_counter<=(OTHERS=>'0');
            ELSE
                baud_counter<=baud_counter+1;
            END IF;
        END IF;
    END PROCESS;
    
    PROCESS(clk, rst)
    BEGIN
        IF rst='1' THEN
            timeout_counter<=(OTHERS=>'0');
        ELSIF rising_edge(clk) THEN
            IF (rx_fifo_empty='1' OR read_RHR='1' OR rx_finished='1') THEN
                clear_cnt<='1';
                timeout_counter<=(OTHERS=>'0');
            ELSIF (rx_fifo_empty='0' AND baud_counter=UNSIGNED(divisor) AND timeout_counter(5)='0') THEN
                timeout_counter<=timeout_counter+1;
                clear_cnt<='1';
            ELSE
                clear_cnt<='0';
            END IF;
        END IF;
    END PROCESS;
    
    rx_char_timeout<=timeout_counter(5);
    
END behavior;
