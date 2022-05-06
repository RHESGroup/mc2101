LIBRARY ieee;
USE ieee.std_logic_1164.ALL;

ENTITY tb_ssram_test IS
END tb_ssram_test;

ARCHITECTURE tb OF tb_ssram_test IS

COMPONENT ssram_test IS 
    GENERIC (
		dataWidth      : INTEGER := 32;
		addressWidth   : INTEGER := 32;
		actual_address : INTEGER := 13;
		size           : INTEGER := 2**actual_address -- 2^12 for data and 2^12 for instr, 4 K each
	);  
	PORT (
		clk           : IN  STD_LOGIC;
		rst           : IN  STD_LOGIC;
		readMem       : IN  STD_LOGIC;
		writeMem      : IN  STD_LOGIC;
		address       : IN  STD_LOGIC_VECTOR (addressWidth - 1 DOWNTO 0);
		dataIn     	  : IN  STD_LOGIC_VECTOR (dataWidth -1 DOWNTO 0);
		byteEn        : IN  STD_LOGIC_VECTOR (1 DOWNTO 0);
		dataOut       : OUT STD_LOGIC_VECTOR (dataWidth -1 DOWNTO 0)
	);
END COMPONENT;
    
    SIGNAL clk      : std_logic;
    SIGNAL rst      : std_logic;
    SIGNAL read     : std_logic;
    SIGNAL write    : std_logic;
    SIGNAL address  : std_logic_vector(31 DOWNTO 0);
    SIGNAL dataIn   : std_logic_vector(31 DOWNTO 0);
    SIGNAL dataOut  : std_logic_vector(31 DOWNTO 0);
    SIGNAL byteEn   : std_logic_vector(1 downto 0);
    
    CONSTANT period : TIME := 30 ns;
    
BEGIN

    uut: ssram_test
        port map(
            clk=>clk,
		    rst=>rst,
		    readMem=>read,
		    writeMem=>write,
		    address=>address,
		    dataIn=>dataIn,
		    byteEn=>byteEn,
		    dataOut=>dataOut
        );

    process
    begin
        clk<='0';
        wait for period/2;
        clk<='1';
        wait for period/2;
    end process;
    
    process
    begin
        read<='0';    
        write<='0';
        byteEn<="11";
        rst<='1';
        wait for 20 ns;
        rst<='0';
        wait for 10 ns;
        --try write without enables
        address<=x"00100000";
        dataIn<=x"00000001";
        wait for 30 ns;
        address<=x"00100004";
        dataIn<=x"00000002";
        wait for 30 ns;
        address<=x"00100008";
        dataIn<=x"00000003";
        wait for 30 ns;
        address<=x"0010000C";
        dataIn<=x"00000004";
        wait for 30 ns;
        --try read without enables
        address<=x"00100000";
        wait for 30 ns;
        address<=x"00100004";
        wait for 30 ns;
        address<=x"00100008";
        wait for 30 ns;
        address<=x"0010000C";
        wait for 30 ns;
        --try read with enables
        read<='1';
        address<=x"00100000";
        wait for 30 ns;
        address<=x"00100004";
        wait for 30 ns;
        address<=x"00100008";
        wait for 30 ns;
        address<=x"0010000C";
        wait for 30 ns;
        --try simple write tests
        write<='1';
        read<='0';
        address<=x"00100000";
        dataIn<=x"00000001";
        wait for 30 ns;
        address<=x"00100004";
        dataIn<=x"00000002";
        wait for 30 ns;
        address<=x"00100008";
        dataIn<=x"00000003";
        wait for 30 ns;
        address<=x"0010000C";
        dataIn<=x"00000004";
        wait for 30 ns;
        --try simple read tests
        write<='0';
        read<='1';
        address<=x"00100000";
        wait for 30 ns;
        address<=x"00100004";
        wait for 30 ns;
        address<=x"00100008";
        wait for 30 ns;
        address<=x"0010000C";
        wait for 30 ns;
        --test pattern(W1,WH1,WB1,R1)
        read<='0';
        write<='1';
        byteEn<="11";
        address<=x"00100000";
        dataIn<=x"ffffffff";
        wait for 30 ns;
        byteEn<="01";
        address<=x"00100000";
        dataIn<=x"00001010";
        wait for 30 ns;
        byteEn<="00";
        address<=x"00100000";
        dataIn<=x"00000001";
        wait for 30 ns;
        write<='0';
        read<='1';
        address<=x"00100000";
        --SHOULD READ: FFFF1001
        wait;
    end process;
    
END tb;

















