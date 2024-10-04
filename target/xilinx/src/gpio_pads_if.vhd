LIBRARY IEEE;
USE IEEE.std_logic_1164.all;


ENTITY gpio_pads_if IS  
    PORT (
        --INPUTS
	    clk:            IN STD_LOGIC;
	    rst:            IN STD_LOGIC;
	    gpios_dir:      IN STD_LOGIC_VECTOR(31 DOWNTO 0);
	    gpios_port_out: IN STD_LOGIC_VECTOR(31 DOWNTO 0);
	    --OUTPUTS
	    gpios_port_in : OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
	    --INOUTS
	    gpios_pin:      INOUT STD_LOGIC_VECTOR(31 DOWNTO 0)
    ); 


    	-- --Marking the signals for debugging	
        attribute mark_debug : string;
        attribute mark_debug of gpios_dir: signal is "true";
    
          
        attribute dont_touch : string;
        attribute dont_touch of gpios_dir: signal is "true";
     
END ENTITY;

ARCHITECTURE struct OF gpio_pads_if IS

    COMPONENT gpio_pad IS
    PORT(
            --INPUTS
            clk:           IN STD_LOGIC;
            rst:           IN STD_LOGIC;
            gpio_dir : IN STD_LOGIC;
            gpio_port_out: IN STD_LOGIC;
            --OUTPUTS
            gpio_port_in : OUT STD_LOGIC;
            --INOUTS
            gpio_pin:  INOUT STD_LOGIC
    );
    END COMPONENT;

BEGIN
    PADS: FOR i IN 0 TO 31 GENERATE 
        PAD: gpio_pad PORT MAP(
            --INPUTS
            clk => clk,
            rst => rst,
            gpio_dir => gpios_dir(i),
            gpio_port_out => gpios_port_out(i),
            --OUTPUTS
            gpio_port_in => gpios_port_in(i),
            --INOUTS
            gpio_pin => gpios_pin(i)
        );
    END GENERATE PADS;

END ARCHITECTURE;