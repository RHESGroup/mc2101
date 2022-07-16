LIBRARY IEEE;
LIBRARY STD;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.NUMERIC_STD.ALL;

ENTITY tb_uart IS 
END tb_uart;

ARCHITECTURE tb OF tb_uart IS
    COMPONENT uart IS 
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
    END COMPONENT;
    
    SIGNAL clk: STD_LOGIC;
    SIGNAL rst: STD_LOGIC;
    SIGNAL address: STD_LOGIC_VECTOR(2 DOWNTO 0);
    SIGNAL busDataIn: STD_LOGIC_VECTOR(7 DOWNTO 0);
    SIGNAL read: STD_LOGIC;
    SIGNAL write: STD_LOGIC;
    SIGNAL RX: STD_LOGIC;
    SIGNAL uart_int: STD_LOGIC;
    SIGNAL TX: STD_LOGIC;
    SIGNAL busDataOut: STD_LOGIC_VECTOR(7 DOWNTO 0);
    
    -- Test Bench uses a 10 MHz Clock
    -- Want to interface to 115200 baud UART
    -- 10000000 / 115200 = 87 Clocks Per Bit.
    CONSTANT c_CLKS_PER_BIT : integer := 87;
    CONSTANT c_DIVISOR : STD_LOGIC_VECTOR(15 DOWNTO 0):= STD_LOGIC_VECTOR(TO_UNSIGNED(c_CLKS_PER_BIT,16) - 1);
    CONSTANT c_BIT_PERIOD : time := 8680 ns;
    
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
  
  SIGNAL rx_data_buffer: STD_LOGIC_VECTOR(7 DOWNTO 0);
  SIGNAL parity_en: STD_LOGIC;
  SIGNAL parity_t: STD_LOGIC;
  SIGNAL stop: STD_LOGIC;
  SIGNAL data_w: STD_LOGIC_VECTOR(1 DOWNTO 0);
    
BEGIN

    UUT_UART: uart 
	PORT MAP(
		clk=>clk,
		rst=>rst,
		address=>address,
		busDataIn=>busDataIn,
		read=>read,
		write=>write,
		uart_rx=>RX,
		interrupt=>uart_int,
		uart_tx=>TX,
		busDataOut=>busDataOut
	);
    
    --10 MHz clock
    PROCESS
    BEGIN
        clk<='0';
        WAIT FOR 50 ns;
        clk<='1';
        WAIT FOR 50 ns;
    END PROCESS;
    
    PROCESS
    BEGIN
        rst<='0';
        write<='0';
        read<='0';
        WAIT FOR 30 ns;
        rst<='1';
        WAIT FOR 30 ns;
        rst<='0';
        WAIT FOR 4 ns;
        --setup baudrate
        --1) set DLAB bit
        WAIT UNTIL rising_edge(clk);
        address<="011";
        busDataIn<="10000000";
        write<='1';
        WAIT UNTIL rising_edge(clk);
        --2) set DLL
        address<="000";
        busDataIn<=c_DIVISOR(7 DOWNTO 0);
        WAIT UNTIL rising_edge(clk);
        --3) set DLM
        address<="001";
        busDataIn<=c_DIVISOR(15 DOWNTO 8);
        WAIT UNTIL rising_edge(clk);
        write<='0';
        WAIT UNTIL rising_edge(clk);
        --setup (8 data bits, No parity, 1 STOP)
        address<="011";
        busDataIn<="00000011";
        write<='1';
        WAIT UNTIL rising_edge(clk);
        write<='0';
        WAIT UNTIL rising_edge(clk);
        --test a simple character transmission
        address<="000";
        busDataIn<="10000001";
        write<='1';
        WAIT UNTIL rising_edge(clk);
        write<='0';
        WAIT FOR 100000 ns;
        WAIT UNTIL rising_edge(clk);
        --test multiple character transmission (3 chars)
        address<="000";
        busDataIn<="10101010";
        write<='1';
        WAIT UNTIL rising_edge(clk);
        busDataIn<="11110000";
        WAIT UNTIL rising_edge(clk);
        busDataIn<="00001111";
        WAIT UNTIL rising_edge(clk);
        write<='0';
        WAIT FOR 300000 ns;
        WAIT UNTIL rising_edge(clk);
        --test interrupt for transmitter empty
        --1) enable THR empty 
        address<="001";
        busDataIn<="00000010";
        write<='1';
        WAIT UNTIL rising_edge(clk);
        write<='0';
        WAIT UNTIL rising_edge(clk);
        WAIT UNTIL rising_edge(clk);
        WAIT UNTIL rising_edge(clk);
        WAIT UNTIL rising_edge(clk);
        --clean the iterrupt by writing to thr
        address<="000";
        busDataIn<="10101010";
        write<='1';
        WAIT UNTIL rising_edge(clk);
        WAIT UNTIL rising_edge(clk);
        WAIT UNTIL rising_edge(clk);
        WAIT UNTIL rising_edge(clk);
        WAIT UNTIL rising_edge(clk);
        WAIT UNTIL rising_edge(clk);
        write<='0';
        WAIT UNTIL rising_edge(clk);
        --clean the fifo by acting on FCR's Tx FIFO Reset
        address<="010";
        busDataIn<="00000100";
        write<='1';
        WAIT UNTIL rising_edge(clk);
        WAIT UNTIL rising_edge(clk);
        write<='0';
        WAIT UNTIL rising_edge(clk);
        WAIT UNTIL rising_edge(clk);
        WAIT UNTIL rising_edge(clk);
        WAIT UNTIL rising_edge(clk);  
        RX<='1';
        WAIT UNTIL rising_edge(clk);
        --Transmitter test
        --Test simple transmission: (8 data bits, No parity, 1 STOP)
        rx_data_buffer<=X"AB";
        parity_en<='0';
        parity_t<='0';
        stop<='0';
        data_w<="11";
        mock_TRANSMITTER(rx_data_buffer, data_w, RX, parity_t, parity_en, stop);
        WAIT UNTIL rising_edge(clk);
        --Read the FIFO to check data correctly received
        address<="000";
        read<='1';
        WAIT;
        
     END PROCESS ;  

END tb;
