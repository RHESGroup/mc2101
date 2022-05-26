LIBRARY IEEE;
LIBRARY STD;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.NUMERIC_STD.ALL;

ENTITY tb_gpio_pads_if IS
END tb_gpio_pads_if;

ARCHITECTURE tb OF tb_gpio_pads_if IS

    COMPONENT gpio_pads_if IS   
    GENERIC (
        BUFFERSIZE: integer:=32
    );
	PORT (
	    gpio_pins:  INOUT STD_LOGIC_VECTOR( BUFFERSIZE-1 DOWNTO 0);
	    gpio_port_in : OUT STD_LOGIC_VECTOR( BUFFERSIZE-1 DOWNTO 0);
	    gpio_pad_dir : IN STD_LOGIC_VECTOR( BUFFERSIZE-1 DOWNTO 0);
	    gpio_port_out: IN STD_LOGIC_VECTOR( BUFFERSIZE-1 DOWNTO 0)
	);
    END COMPONENT;
    
    SIGNAL gpio_pins: STD_LOGIC_VECTOR(3 DOWNTO 0);
    SIGNAL gpio_port_in: STD_LOGIC_VECTOR(3 DOWNTO 0);
    SIGNAL gpio_pad_dir: STD_LOGIC_VECTOR(3 DOWNTO 0);
    SIGNAL gpio_port_out: STD_LOGIC_VECTOR(3 DOWNTO 0);

BEGIN

    uut: gpio_pads_if  
    GENERIC MAP(
        BUFFERSIZE=>4
    )
	PORT MAP(
	    gpio_pins=>gpio_pins,
	    gpio_port_in=>gpio_port_in,
	    gpio_pad_dir=>gpio_pad_dir,
	    gpio_port_out=>gpio_port_out
	);

    PROCESS
    BEGIN
        --all inputs
        gpio_pad_dir<=(OTHERS=>'0');
        --should read all 0
        gpio_pins<=(OTHERS=>'0');
        --this outputs should be ignored
        gpio_port_out<=(OTHERS=>'1');
        WAIT FOR 10 ns;
        --all inputs
        gpio_pad_dir<=(OTHERS=>'0');
        --should read all 1
        gpio_pins<=(OTHERS=>'1');
        --this outputs should be ignored
        gpio_port_out<=(OTHERS=>'1');
        WAIT FOR 10 ns;
        --OUT-IN-OUT-IN
        gpio_pad_dir<="1010";
        --write on pins 1 and 3 (NO CONFLICT SHOULD HAPPEN)
        gpio_pins(0)<='1';
        gpio_pins(2)<='0';
        --pin 0 and 1 are written with 1
        gpio_port_out<=(OTHERS=>'1');
        --the overall situation of the gpio_pins should be: 1101
        WAIT;
    END PROCESS;
    
END tb;
