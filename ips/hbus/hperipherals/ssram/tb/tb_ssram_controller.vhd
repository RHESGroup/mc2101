LIBRARY ieee;
USE ieee.std_logic_1164.ALL;

ENTITY tb_ssram_controller IS
END tb_ssram_controller;

ARCHITECTURE tb OF tb_ssram_controller IS

    COMPONENT ssram_controller IS 
	PORT (
	    --system signals
		clk           : IN  STD_LOGIC;
		rst           : IN  STD_LOGIC;
		--input
		chip_select   : IN  STD_LOGIC;
		request       : IN  STD_LOGIC;
		--output
		memRead       : OUT STD_LOGIC;
		memWrite      : OUT STD_LOGIC;
		memSelByte    : OUT STD_LOGIC_VECTOR(1 DOWNTO 0);
		memResponse   : OUT STD_LOGIC;
		latchInEn     : OUT STD_LOGIC;
		memReady      : OUT STD_LOGIC
	);
	END COMPONENT;
    
    SIGNAL clk: STD_LOGIC; 
    SIGNAL rst: STD_LOGIC;
    SIGNAL hsel: STD_LOGIC;
    SIGNAL hwrite: STD_LOGIC;
    SIGNAL memRead: STD_LOGIC;
    SIGNAL memWrite: STD_LOGIC;
    SIGNAL memSelByteOut: STD_LOGIC_VECTOR(1 DOWNTO 0);
    SIGNAL memResponse: STD_LOGIC;
    SIGNAL memReady: STD_LOGIC;
    SIGNAL latchInEn: STD_LOGIC;
    
    CONSTANT period : TIME := 30 ns;

BEGIN

    uut: ssram_controller
        port map(
            clk=>clk,
		    rst=>rst,
		    chip_select=>hsel,
		    request=>hwrite,
		    memRead=>memRead,
		    memWrite=>memWrite,
		    memSelByte=>memSelByteOut,
		    memResponse=>memResponse,
		    latchInEn=>latchInEn,
		    memReady=>memReady
        );

    PROCESS
    BEGIN
        clk<='0';
        WAIT FOR period/2;
        clk<='1';
        WAIT FOR period/2;
    END PROCESS;
    
    PROCESS
    BEGIN
        rst<='1';
        hsel<='0';
        hwrite<='0';
        WAIT FOR 20 ns;
        rst<='0';
        WAIT FOR 10 ns;
        --series of read operation without hsel='0'
        WAIT FOR period;
        WAIT FOR period;
        WAIT FOR period;
        WAIT FOR period;
        --series of write operation without hsel='0';
        hwrite<='1';
        WAIT FOR period;
        WAIT FOR period;
        WAIT FOR period;
        WAIT FOR period;
        --4 byte write operation
        hsel<='1';
        hwrite<='1';
        WAIT FOR period;
        WAIT FOR period;
        WAIT FOR period;
        WAIT FOR period;
        hsel<='0';
        hwrite<='0';
        WAIT FOR PERIOD;
        --2 byte write operation
        hsel<='1';
        hwrite<='1';
        WAIT FOR period;
        WAIT FOR period;
        hsel<='0';
        hwrite<='0';
        WAIT FOR PERIOD;
        --1 byte write operation
        hsel<='1';
        hwrite<='1';
        WAIT FOR period;
        hsel<='0';
        hwrite<='0';
        WAIT FOR period;
        --4 byte read operation
        hsel<='1';
        hwrite<='0';
        WAIT FOR period;
        WAIT FOR period;
        WAIT FOR period;
        WAIT FOR period;
        WAIT FOR period;
        hsel<='0';
        WAIT FOR period;
        --2 byte read operation
        hsel<='1';
        WAIT FOR period;
        WAIT FOR period;
        WAIT FOR period;
        hsel<='0';
        WAIt FOR period;
        --1 byte read operation
        hsel<='1';
        WAIT FOR period;
        WAIT FOR period;
        hsel<='0';
        WAIT;
    END PROCESS;
END tb;






