LIBRARY ieee;
USE ieee.std_logic_1164.ALL;

ENTITY tb_flash_bus_wrap IS
END tb_flash_bus_wrap;

ARCHITECTURE tb OF tb_flash_bus_wrap IS

    COMPONENT flash_bus_wrap IS
	GENERIC (
		busDataWidth      : INTEGER := 8;
		busAddressWidth   : INTEGER := 32
	);  
	PORT (
	    --system signals
		clk           : IN  STD_LOGIC;
		rst           : IN  STD_LOGIC;
		--master driven signals
		htrans        : IN  STD_LOGIC_VECTOR(1 DOWNTO 0);
		hselx         : IN  STD_LOGIC;
		hwrite        : IN  STD_LOGIC;
		hwrdata       : IN  STD_LOGIC_VECTOR(busDataWidth-1 DOWNTO 0);
		haddr         : IN  STD_LOGIC_VECTOR(busAddressWidth-1 DOWNTO 0);
		--slave driven signals
		hrdata        : OUT STD_LOGIC_VECTOR(busDataWidth-1 DOWNTO 0);
		hready        : OUT STD_LOGIC;
		hresp         : OUT STD_LOGIC
	);
    END COMPONENT;
    
    SIGNAL hstatus: STD_LOGIC_VECTOR(1 DOWNTO 0); --unused for the moment
    SIGNAL hselx:   STD_LOGIC;
    SIGNAL hwrite:  STD_LOGIC;
    SIGNAL hwrdata: STD_LOGIC_VECTOR(7 DOWNTO 0);
    SIGNAL haddr:   STD_LOGIC_VECTOR(31 DOWNTO 0);
    SIGNAL hrdata:  STD_LOGIC_VECTOR(7 DOWNTO 0);
    SIGNAL hready:  STD_LOGIC;
    SIGNAL hresp:   STD_LOGIC;
    SIGNAL clk,rst: STD_LOGIC;
    
    CONSTANT period : TIME := 30 ns;
    
    CONSTANT FLASH_BASE: STD_LOGIC_VECTOR(31 DOWNTO 0):=x"1A100000";

BEGIN

    ssram_interface: flash_bus_wrap
	GENERIC MAP(
		busDataWidth      =>8,
		busAddressWidth   =>32
	)
	PORT MAP(
		clk               =>clk,
		rst               =>rst,
		htrans            =>"00",
		hselx             =>hselx,
		hwrite            =>hwrite,
		hwrdata           =>hwrdata,
		haddr             =>haddr,
		hrdata            =>hrdata,
		hready            =>hready,
		hresp             =>hresp
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
        hselx<='0';
        hwrite<='0';
        hwrdata<=(OTHERS=>'0');
        haddr<=FLASH_BASE;
        WAIT FOR 10 ns;
        rst<='0';
        WAIT FOR 10 ns;
        WAIT FOR 10 ns;
        WAIT FOR 10 ns;
        WAIT FOR 10 ns;
        WAIT FOR 10 ns;
        --not enabed perpheral should stay idle
        hselx<='0';
        hwrite<='0';
        WAIT FOR 10 ns;
        WAIT FOR 10 ns;
        WAIT FOR 10 ns;
        WAIT FOR 10 ns;
        --write operation should be ignored, peripheral should stay idle
        hselx<='1';
        hwrite<='1';
        WAIT FOR 10 ns;
        WAIT FOR 10 ns;
        WAIT FOR 10 ns;
        WAIT FOR 10 ns;
        WAIT FOR 10 ns;
        WAIT FOR 10 ns;
        WAIT FOR 10 ns;
        --read operation
        hwrite<='0';
        WAIT FOR 10 ns;
        WAIT FOR 10 ns;
        WAIT FOR 10 ns;
        WAIT FOR 10 ns;
        WAIT FOR 10 ns;
        WAIT FOR 10 ns;
        WAIT FOR 10 ns;
        haddr<=x"1A100001";
        WAIT FOR 10 ns;
        WAIT FOR 10 ns;
        WAIT FOR 10 ns;
        WAIT FOR 10 ns;
        WAIT FOR 10 ns;
        WAIT FOR 10 ns;
        haddr<=x"1A100FFF";
        WAIT FOR 10 ns;
        WAIT FOR 10 ns;
        WAIT FOR 10 ns;
        WAIT FOR 10 ns;
        WAIT FOR 10 ns;
        WAIT;
    END PROCESS;
    

END tb;
