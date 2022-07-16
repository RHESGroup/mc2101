LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.all;
 
ENTITY tb_uart_tx_core is
END tb_uart_tx_core;

ARCHITECTURE behave OF tb_uart_tx_core IS
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
		tx_busy         : OUT STD_LOGIC; --transmitter is sending 
		tx_ready        : OUT STD_LOGIC; --transmitter ready for next data
		tx_out          : OUT STD_LOGIC --TX line
	);
    END COMPONENT;
    
    -- Test Bench uses a 10 MHz Clock
  -- Want to interface to 115200 baud UART
  -- 10000000 / 115200 = 87 Clocks Per Bit.
  CONSTANT c_CLKS_PER_BIT : integer := 87;
  CONSTANT c_DIVISOR : STD_LOGIC_VECTOR(15 DOWNTO 0):= STD_LOGIC_VECTOR(TO_UNSIGNED(c_CLKS_PER_BIT,16) - 1);
 
  CONSTANT c_BIT_PERIOD : time := 8680 ns;
   
  SIGNAL t_CLOCK     : STD_LOGIC                    := '0';
  SIGNAL t_TX_BYTE   : STD_LOGIC_VECTOR(7 DOWNTO 0) := (OTHERS => '0');
  SIGNAL t_TX_SERIAL : STD_LOGIC:='1';
  SIGNAL rst: STD_LOGIC:='1';
  SIGNAL p_ENABLE: STD_LOGIC := '0';
  SIGNAL p_TYPE:    STD_LOGIC := '0';
  SIGNAL data_WIDTH: STD_LOGIC_VECTOR(1 DOWNTO 0) := "11" ;
  SIGNAL tx_BUSY: STD_LOGIC;
  SIGNAL tx_READY: STD_LOGIC;
  SIGNAL tx_VALID: STD_LOGIC;
  SIGNAL parity: STD_LOGIC;
  SIGNAL stop_bit: STD_LOGIC := '1';  
  SIGNAL gold_serial: STD_LOGIC;

BEGIN

    TX: uart_tx_core
	PORT MAP (
		clk=> t_CLOCK,
		rst=> rst,
		divisor=> c_DIVISOR,
		parity_bit_en=> p_ENABLE,
		parity_type=> p_TYPE,
		data_width=> data_WIDTH,
		stop_bits=> stop_bit,
		tx_data_i=> t_TX_BYTE,
		tx_valid=> tx_VALID,
		tx_busy=> tx_BUSY,
		tx_ready=> tx_READY,
		tx_out=> t_TX_SERIAL
	);

    --10 MHz clock
    t_CLOCK <= NOT t_CLOCK AFTER 50 ns;

    PROCESS
    BEGIN
        rst<='1';
        WAIT FOR 20 ns;
        rst<='0';
        
        --TEST 1: TRANSMIT(8 DATA BITS, NO PARITY, 1 STOP)
        data_WIDTH<="11";
        p_ENABLE<='0';
        parity<='0';
        t_TX_BYTE<=X"0F";
        stop_bit<='0';
        tx_VALID<='0';
        WAIT FOR 125 ns;
        tx_VALID<='1';
        WAIT FOR 125 ns;
        tx_VALID<='0';
        
        WAIT UNTIL tx_READY='1';
        
        --TEST 2: TRANSMIT(7 DATA BITS, PARITY, 1 STOP)
        data_WIDTH<="10";
        t_TX_BYTE<=X"F0";
        p_ENABLE<='1';
        parity<='1';
        stop_bit<='0';
        WAIT FOR 125 ns;
        tx_VALID<='1';
        WAIT FOR 125 ns;
        tx_VALID<='0';
        
        WAIT UNTIL tx_READY='1';
        
        --TEST 2: TRANSMIT(5 DATA BITS, PARITY, 2 STOP)
        data_WIDTH<="10";
        t_TX_BYTE<=X"00";
        p_ENABLE<='1';
        parity<='0';
        t_TX_BYTE<=X"00";
        stop_bit<='1';
        WAIT FOR 125 ns;
        tx_VALID<='1';
        WAIT FOR 125 ns;
        tx_VALID<='0';
        
        WAIT;
        
    END PROCESS;

  -- GOLD Transmitter
  -- baudrate   : 115200 bps
  PROCESS
    VARIABLE DATA_W: INTEGER;
  BEGIN
    gold_serial<='1';
    WAIT UNTIL tx_VALID='1';
    --data width configuration
    IF data_WIDTH="00" THEN
        DATA_W:=4;
    ELSIF data_WIDTH="01" THEN
        DATA_W:=5;
    ELSIF data_WIDTH="10" THEN
        DATA_W:=6;
    ELSE
        DATA_W:=7;
    END IF; 
    -- Send Start Bit
    gold_serial <= '0';
    WAIT FOR c_BIT_PERIOD;
    -- Send Data Bit
    FOR ii IN 0 TO DATA_W LOOP
      gold_serial <= t_TX_BYTE(ii);
      WAIT FOR c_BIT_PERIOD;
    END LOOP;  -- ii  
    --Send Parity Bit if enabled
    IF p_ENABLE='1' THEN
        gold_serial <= parity;
        WAIT FOR c_BIT_PERIOD;
    END IF;
    -- Send Stop Bit
    gold_serial <= '1';
    WAIT FOR c_BIT_PERIOD;
  END PROCESS;

END behave;
