LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.all;
 
ENTITY tb_uart_interrupt is
END tb_uart_interrupt;
 
ARCHITECTURE tb OF tb_uart_interrupt IS
 
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
		IER                 : IN  STD_LOGIC_VECTOR(7 DOWNTO 0); --Interrupt Enable Register
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
  
  SIGNAL clk, rst : STD_LOGIC;
  SIGNAL IER :STD_LOGIC_VECTOR(7 DOWNTO 0);	
  SIGNAL rx_fifo_trigger_lv  :STD_LOGIC_VECTOR(1 DOWNTO 0);
  SIGNAL rx_elements :STD_LOGIC_VECTOR(3 DOWNTO 0);
  SIGNAL tx_elements :STD_LOGIC_VECTOR(3 DOWNTO 0);
  SIGNAL rx_line_error :STD_LOGIC;
  SIGNAL interrupt_clear :STD_LOGIC;
  SIGNAL rx_data_ready :STD_LOGIC;
  SIGNAL char_timeout :STD_LOGIC;
  SIGNAL interrupt :STD_LOGIC;
  SIGNAL interrupt_isr_code :STD_LOGIC_VECTOR(3 DOWNTO 0);
  
  
BEGIN

    U_INT: uart_interrupt
    GENERIC MAP(
        FIFO_DEPTH=>8,
        LOG_FIFO_D=>3
    )
	PORT MAP(
		clk=>clk,
		rst=>rst,
		IER=>IER,
		rx_fifo_trigger_lv=>rx_fifo_trigger_lv,
		rx_elements=>rx_elements,
		tx_elements=>tx_elements,
		rx_line_error=>rx_line_error,
		interrupt_clear=>interrupt_clear,
		rx_data_ready=>rx_data_ready,
		char_timeout=>char_timeout,
		interrupt=>interrupt,
		interrupt_isr_code=>interrupt_isr_code
	);

    PROCESS
    BEGIN
        clk<='0';
        WAIT FOR 25 ns;
        clk<='1';
        WAIT FOR 25 ns;
    END PROCESS;
    
    PROCESS
    BEGIN
        rst<='0';
        WAIT FOR 30 ns;
        rst<='1';
        WAIT FOR 30 ns;
        rst<='0';
        WAIT FOR 4 ns;
        --all interrupt are disabled, whatever happens the interrupt line should be low
        IER<=(OTHERS=>'0');
        rx_fifo_trigger_lv<=(OTHERS=>'0');
        rx_elements<=(OTHERS=>'0');
        tx_elements<=(OTHERS=>'0');
        rx_line_error<='0';
        interrupt_clear<='0';
        rx_data_ready<='0';
        char_timeout<='0';
        WAIT FOR 120 ns;
        --1) TEST: Receiver Line Status
        rx_line_error<='1';
        WAIT FOR 120 ns;
        --enable RLS interrupt
        IER<="00000100";
        WAIT FOR 120 ns;
        --clear interrupt
        interrupt_clear<='1';
        WAIT FOR 120 ns;
        IER<="00000000";
        rx_line_error<='0';
        WAIT FOR 50 ns;
        interrupt_clear<='0';
        WAIT FOR 120 ns;
        --2) TEST Receiver data Ready
        rx_data_ready<='1';
        tx_elements<="1111";
        WAIT FOR 120 ns;
        --enable DR interrupt
        IER<="00000001";
        WAIT FOR 120 ns;
        --clear interrupt
        interrupt_clear<='1';
        WAIT FOR 120 ns;
        --test data ready with trigger level
        interrupt_clear<='0';
        --interrupt should not rise because trigger level is 1
        rx_elements<="0000";
        WAIT FOR 120 ns;
        --interrupt should rise because rigger level is 1 and tx_elements=1
        rx_elements<="0001";
        WAIT FOR 120 ns;
        --clear interrupt
        interrupt_clear<='1';
        rx_elements<="0000";
        IER<="00000000";
        WAIT FOR 120 ns;
        interrupt_clear<='0';
        --3) TEST: reception timeout 
        char_timeout<='1';
        WAIT FOR 120 ns;
        --enable DR interrupt
        IER<="00000001";
        WAIT FOR 120 ns;
        --clear interrupt
        interrupt_clear<='1';
        char_timeout<='0';
        WAIT FOR 120 ns;
        interrupt_clear<='0';
        IER<="00000000";
        WAIT FOR 120 ns;
        --4) TEST: THR empty
        rx_elements<="0000";
        WAIT FOR 120 ns;
        -- enable THR emoty interrupt
        IER<="00000010";
        WAIT FOR 120 ns;
        --5) TEST: test priority, line status error should be prioritized
        IER<="00000011";
        WAIT FOR 120 ns;
        rx_line_error<='0';
        WAIT FOR 120 ns;
        rx_line_error<='1';
        WAIT FOR 120 ns;
        --6) TEST: interrupt should be kept raised until cleared
        IER<="00000000";
        rx_line_error<='0';
        WAIT FOR 120 ns;
        WAIT FOR 120 ns;
        --clear
        interrupt_clear<='1';
        WAIT;
    END PROCESS;

END tb;
