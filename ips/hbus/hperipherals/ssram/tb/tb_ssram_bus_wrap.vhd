LIBRARY ieee;
USE ieee.std_logic_1164.ALL;

ENTITY tb_ssram_bus_wrap IS
END tb_ssram_bus_wrap;

ARCHITECTURE tb OF tb_ssram_bus_wrap IS

    COMPONENT ssram_bus_wrap IS
	GENERIC (
		busDataWidth      : INTEGER := 8;
		busAddressWidth   : INTEGER := 32
	);  
	PORT (
		clk           : IN  STD_LOGIC;
		rst           : IN  STD_LOGIC;
		--master driven signals
		hstatus       : IN  STD_LOGIC_VECTOR(1 DOWNTO 0);
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

BEGIN

    ssram_interface: ssram_bus_wrap
	GENERIC MAP(
		busDataWidth      =>8,
		busAddressWidth   =>32
	)
	PORT MAP(
		clk               =>clk,
		rst               =>rst,
		hstatus           =>"00",
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
        haddr<=(OTHERS=>'0');
        WAIT FOR 10 ns;
        rst<='0';
        WAIT FOR 10 ns;
        --4 byte read operation without hselx='0'
        haddr<=x"00100000";
        WAIT FOR period;
        WAIT FOR period;
        WAIT FOR period;
        WAIT FOR period;
        WAIT FOR period;
        --pause
        hselx<='0';
        hwrite<='0';
        WAIT FOR period;
        --4 byte write operation without hselx='0';
        hwrite<='1';
        haddr<=x"00100000";
        hwrdata<=x"FF";
        WAIT FOR period;
        hwrdata<=x"FF";
        WAIT FOR period;
        hwrdata<=x"FF";
        WAIT FOR period;
        hwrdata<=x"FF";
        WAIT FOR period;
        --pause
        hselx<='0';
        hwrite<='0';
        WAIT FOR period;
        --4 byte read operation
        hselx<='1';
        haddr<=x"00100000";
        WAIT FOR period;
        WAIT FOR period;
        WAIT FOR period;
        WAIT FOR period;
        WAIT FOR period;
        --pause
        hselx<='0';
        hwrite<='0';
        WAIT FOR period;
        --4 byte write operation
        hselx<='1';
        hwrite<='1';
        haddr<=x"00100000";
        hwrdata<=x"FF";
        WAIT FOR period;
        hwrdata<=x"FF";
        WAIT FOR period;
        hwrdata<=x"FF";
        WAIT FOR period;
        hwrdata<=x"FF";
        WAIT FOR period;
        --pause
        hselx<='0';
        hwrite<='0';
        WAIT FOR period;
        --4 byte read operation
        hselx<='1';
        haddr<=x"00100000";
        WAIT FOR period;
        WAIT FOR period;
        WAIT FOR period;
        WAIT FOR period;
        WAIT FOR period;
        --pause
        hselx<='0';
        hwrite<='0';
        WAIT FOR period;
        --2 byte write operation
        hselx<='1';
        hwrite<='1';
        haddr<=x"00100000";
        hwrdata<=x"10";
        WAIT FOR period;
        hwrdata<=x"10";
        WAIT FOR period;
        --pause
        hselx<='0';
        hwrite<='0';
        WAIT FOR period;
        --1 byte write operation
        hselx<='1';
        hwrite<='1';
        haddr<=x"00100000";
        hwrdata<=x"01";
        WAIT FOR period;
        --pause
        hselx<='0';
        hwrite<='0';
        WAIT FOR period;
        --4 byte read operation
        hselx<='1';
        hwrite<='0';
        haddr<=x"00100000";
        WAIT FOR period;
        WAIT FOR period;
        WAIT FOR period;
        WAIT FOR period;
        WAIT FOR period;
        --pause
        hselx<='0';
        hwrite<='0';
        WAIT FOR period;
        --2 byte read operation
        hselx<='1';
        WAIT FOR period;
        WAIT FOR period;
        WAIT FOR period;
        --pause
        hselx<='0';
        hwrite<='0';
        WAIT FOR period;
        --1 byte read operation
        hselx<='1';
        WAIT FOR period;
        WAIT FOR period;
        --pause
        hselx<='0';
        hwrite<='0';
        WAIT;
    END PROCESS;
    

END tb;
