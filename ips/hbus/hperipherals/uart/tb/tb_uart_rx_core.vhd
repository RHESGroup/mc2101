LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.all;
 
ENTITY tb_uart_rx_core is
END tb_uart_rx_core;
 
ARCHITECTURE behave OF tb_uart_rx_core IS
 
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
		rx_ready        : IN  STD_LOGIC; --FIFO status
		rx_in_async     : IN  STD_LOGIC; --RX line
		--output signals signals
		line_error      : OUT STD_LOGIC; --parity error OR break interrupt OR frame error
		break_interrupt : OUT STD_LOGIC; --break interrupt
		frame_error     : OUT STD_LOGIC; --frame error
		parity_error    : OUT STD_LOGIC; --parity error
		rx_busy         : OUT STD_LOGIC; --receiver is not in IDLE state (so it's sampling the RX line)
		rx_data_buffer  : OUT STD_LOGIC_VECTOR(7 DOWNTO 0); --registered data
		rx_valid        : OUT STD_LOGIC --data correctly sampled
	);
  END COMPONENT;
 
   
  -- Test Bench uses a 10 MHz Clock
  -- Want to interface to 115200 baud UART
  -- 10000000 / 115200 = 87 Clocks Per Bit.
  CONSTANT c_CLKS_PER_BIT : integer := 87;
  CONSTANT c_DIVISOR : STD_LOGIC_VECTOR(15 DOWNTO 0):= STD_LOGIC_VECTOR(TO_UNSIGNED(c_CLKS_PER_BIT,16) - 1);
 
  CONSTANT c_BIT_PERIOD : time := 8680 ns;
   
  SIGNAL r_CLOCK     : STD_LOGIC                    := '0';
  SIGNAL r_TX_BYTE   : STD_LOGIC_VECTOR(7 DOWNTO 0) := (OTHERS => '0');
  SIGNAL r_TX_SERIAL : STD_LOGIC:='1';
  SIGNAL r_RX_BYTE   : STD_LOGIC_VECTOR(7 DOWNTO 0);
  SIGNAL rst: STD_LOGIC:='1';
  SIGNAL p_ENABLE: STD_LOGIC := '0';
  SIGNAL p_TYPE:    STD_LOGIC := '0';
  SIGNAL data_WIDTH: STD_LOGIC_VECTOR(1 DOWNTO 0) := "11" ;
  SIGNAL s_BITS : STD_LOGIC := '0';
  SIGNAL line_ERROR: STD_LOGIC;
  SIGNAL BI: STD_LOGIC;
  SIGNAL FE: STD_LOGIC;
  SIGNAL PE: STD_LOGIC;
  SIGNAL rx_BUSY: STD_LOGIC;
  SIGNAL rx_VALID: STD_LOGIC;
  SIGNAL parity: STD_LOGIC;
  SIGNAL stop_bit: STD_LOGIC := '1'; 
  
  -- Transmitter as a procedure
  -- baudrate   : 115200 bps
  PROCEDURE mock_TRANSMITTER (
    SIGNAL i_data_in        : IN  STD_LOGIC_VECTOR(7 DOWNTO 0);
    SIGNAL i_data_width     : IN  STD_LOGIC_VECTOR(1 DOWNTO 0);
    SIGNAL o_serial         : OUT STD_LOGIC;
    SIGNAL i_parity         : IN  STD_LOGIC;
    SIGNAL i_parity_enable  : IN  STD_LOGIC;
    SIGNAL i_stop           : IN  STD_LOGIC
    ) IS
    VARIABLE DATA_W: INTEGER;
  BEGIN
    --data width configuration
    IF i_data_width="00" THEN
        DATA_W:=4;
    ELSIF i_data_width="01" THEN
        DATA_W:=5;
    ELSIF i_data_width="10" THEN
        DATA_W:=6;
    ELSE
        DATA_W:=7;
    END IF;
    
    -- Send Start Bit
    o_serial <= '0';
    WAIT FOR c_BIT_PERIOD;
 
    -- Send Data Bit
    FOR ii IN 0 TO DATA_W LOOP
      o_serial <= i_data_in(ii);
      WAIT FOR c_BIT_PERIOD;
    END LOOP;  -- ii
    
    --Send Parity Bit if enabled
    IF i_parity_enable='1' THEN
        o_serial <= i_parity;
        WAIT FOR c_BIT_PERIOD;
    END IF;
 
    -- Send Stop Bit
    o_serial <= i_stop;
    WAIT FOR c_BIT_PERIOD;
  END mock_TRANSMITTER;
 
   
BEGIN

    
  RX: uart_rx_core
	PORT MAP(
		clk=>r_CLOCK,
		rst=>rst,
		divisor=>c_DIVISOR,
		parity_bit_en=>p_ENABLE,
		parity_type=>p_TYPE,
		data_width=>data_WIDTH,
		stop_bits=>s_BITS,
		error_clear=>'1',
		rx_ready=>'1',
		rx_in_async=>r_TX_SERIAL,
		line_error=>line_ERROR,
		break_interrupt=>BI,
		frame_error=>FE,
		parity_error=>PE,
		rx_busy=>rx_BUSY,
		rx_data_buffer=>r_RX_BYTE,
		rx_valid=>rx_VALID
	);
 
  --10 MHz clock
  r_CLOCK <= NOT r_CLOCK AFTER 50 ns;
  
   
  PROCESS
  BEGIN
  
    rst<='1';
    WAIT FOR 20 ns;
    rst<='0';
    data_WIDTH<="11";
    p_ENABLE<='0';
    parity<='0';

    --##############################################################################
    --TEST NUMBER 1: check simple transmission @115200 (8 DATA BITS, NO PARITY, 1 STOP)
    --NO PARITY BIT
    --THE TRANSMITTER IS CONFIGURED IN SUCH A WAY THAT SHOULD NOT RAISE ANY ERRORS!
    --  NO PARITY ERROR
    --  NO FRAME ERROR
    --  NO BREAK INTERRUPT
    WAIT UNTIL rising_edge(r_CLOCK);
    WAIT UNTIL rising_edge(r_CLOCK);
    WAIT UNTIL rising_edge(r_CLOCK);
      
    -- Send a character to the transmitter
    r_TX_BYTE<=X"3F"; --data to be transmitted
    WAIT UNTIL rising_edge(r_CLOCK); 
    mock_TRANSMITTER(r_TX_BYTE, data_WIDTH, r_TX_SERIAL, parity, p_ENABLE, stop_bit);
    WAIT UNTIL rising_edge(r_CLOCK);
    -- Check that the correct command was received
    IF r_RX_BYTE = X"3F" THEN
      REPORT "Test 1 Passed - Correct Byte Received" SEVERITY NOTE;
    ELSE
      REPORT "Test 1 Failed - Incorrect Byte Received" SEVERITY NOTE;
    END IF;
    
    WAIT UNTIL rising_edge(r_CLOCK);
    WAIT UNTIL rising_edge(r_CLOCK);
    WAIT UNTIL rising_edge(r_CLOCK);
    --##############################################################################
    
    data_WIDTH<="11";
    p_ENABLE<='1';
    parity<='1';
    
    --##############################################################################
    --TEST NUMBER 2: check transmission @115200 (8 DATA BITS, PARITY, 1 STOP)
    --THE TRANSMITTER IS CONFIGURED IN SUCH A WAY THAT SHOULD NOT RAISE ANY ERRORS!
    --  NO PARITY ERROR: parity bit is sent correctly
    --  NO FRAME ERROR
    --  NO BREAK INTERRUPT
    WAIT UNTIL rising_edge(r_CLOCK);
    WAIT UNTIL rising_edge(r_CLOCK);
    WAIT UNTIL rising_edge(r_CLOCK);
      
    -- Send a character to the transmitter
    r_TX_BYTE<=X"00"; --data to be transmitted
    WAIT UNTIL rising_edge(r_CLOCK);
    mock_TRANSMITTER(r_TX_BYTE, data_WIDTH, r_TX_SERIAL, parity, p_ENABLE, stop_bit);
    WAIT UNTIL rising_edge(r_CLOCK);
    -- Check that the correct command was received
    IF r_RX_BYTE = X"00" THEN
      REPORT "Test 2 Passed - Correct Byte Received" SEVERITY NOTE;
    ELSE
      REPORT "Test 2 Failed - Incorrect Byte Received" SEVERITY NOTE;
    END IF;
    
    WAIT UNTIL rising_edge(r_CLOCK);
    WAIT UNTIL rising_edge(r_CLOCK);
    WAIT UNTIL rising_edge(r_CLOCK);
    --##############################################################################
    
    data_WIDTH<="11";
    p_ENABLE<='1';
    parity<='0';
    
    --##############################################################################
    --TEST NUMBER 3: check transmission @115200 (8 DATA BITS, PARITY, 1 STOP)
    --Parity bit sent is incorrect
    --  PARITY ERROR: should be raised by the receiver
    --  NO FRAME ERROR
    --  NO BREAK INTERRUPT: stop bit is sent correctly
    WAIT UNTIL rising_edge(r_CLOCK);
    WAIT UNTIL rising_edge(r_CLOCK);
    WAIT UNTIL rising_edge(r_CLOCK);
      
    -- Send a character to the transmitter
    r_TX_BYTE<=X"00"; --data to be transmitted
    WAIT UNTIL rising_edge(r_CLOCK);
    mock_TRANSMITTER(r_TX_BYTE, data_WIDTH, r_TX_SERIAL, parity, p_ENABLE, stop_bit);
    WAIT UNTIL rising_edge(r_CLOCK);
    -- Check that the correct command was received
    IF r_RX_BYTE = X"00" THEN
      REPORT "Test 3 Passed - Correct Byte Received" SEVERITY NOTE;
    ELSE
      REPORT "Test 3 Failed - Incorrect Byte Received" SEVERITY NOTE;
    END IF;
    
    WAIT UNTIL rising_edge(r_CLOCK);
    WAIT UNTIL rising_edge(r_CLOCK);
    WAIT UNTIL rising_edge(r_CLOCK);
    --##############################################################################
    
    data_WIDTH<="00";
    p_ENABLE<='0';
    parity<='0';
    
    --##############################################################################
    --TEST NUMBER 4: check transmission @115200 (5 DATA BITS, NO PARITY, 1 STOP)
    --THE TRANSMITTER IS CONFIGURED IN SUCH A WAY THAT SHOULD NOT RAISE ANY ERRORS!
    --  NO PARITY ERROR
    --  NO FRAME ERROR
    --  NO BREAK INTERRUPT
    WAIT UNTIL rising_edge(r_CLOCK);
    WAIT UNTIL rising_edge(r_CLOCK);
    WAIT UNTIL rising_edge(r_CLOCK);
      
    -- Send a character to the transmitter
    r_TX_BYTE<=X"0F"; --data to be transmitted
    WAIT UNTIL rising_edge(r_CLOCK);
    mock_TRANSMITTER(r_TX_BYTE, data_WIDTH, r_TX_SERIAL, parity, p_ENABLE, stop_bit);
    WAIT UNTIL rising_edge(r_CLOCK);
    -- Check that the correct command was received
    IF r_RX_BYTE = X"0F" THEN
      REPORT "Test 4 Passed - Correct Byte Received" SEVERITY NOTE;
    ELSE
      REPORT "Test 4 Failed - Incorrect Byte Received" SEVERITY NOTE;
    END IF;
    
    WAIT UNTIL rising_edge(r_CLOCK);
    WAIT UNTIL rising_edge(r_CLOCK);
    WAIT UNTIL rising_edge(r_CLOCK);
    --##############################################################################
    
    data_WIDTH<="00";
    p_ENABLE<='1';
    parity<='0';
    stop_bit<='0';
    
    --##############################################################################
    --TEST NUMBER 5: check transmission @115200 (5 DATA BITS, PARITY, 1 STOP)
    --parity sent is incorrect and stop bit is missing
    --  PARITY ERROR
    --  FRAME ERROR
    --  NO BREAK INTERRUPT
    WAIT UNTIL rising_edge(r_CLOCK);
    WAIT UNTIL rising_edge(r_CLOCK);
    WAIT UNTIL rising_edge(r_CLOCK);
      
    -- Send a character to the transmitter
    r_TX_BYTE<=X"0F"; --data to be transmitted
    WAIT UNTIL rising_edge(r_CLOCK);
    mock_TRANSMITTER(r_TX_BYTE, data_WIDTH, r_TX_SERIAL, parity, p_ENABLE, stop_bit);
    WAIT UNTIL rising_edge(r_CLOCK);
    -- Check that the correct command was received
    IF r_RX_BYTE = X"0F" THEN
      REPORT "Test 5 Passed - Correct Byte Received" SEVERITY NOTE;
    ELSE
      REPORT "Test 5 Failed - Incorrect Byte Received" SEVERITY NOTE;
    END IF;
    
    WAIT UNTIL rising_edge(r_CLOCK);
    WAIT UNTIL rising_edge(r_CLOCK);
    WAIT UNTIL rising_edge(r_CLOCK);
    --ASSERT false REPORT "Tests Complete" SEVERITY FAILURE;
    WAIT;
  END PROCESS;
   
END behave;
