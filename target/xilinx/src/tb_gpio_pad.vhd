LIBRARY IEEE;
USE IEEE.std_logic_1164.all;

ENTITY tb_gpio_pad IS
END ENTITY;

ARCHITECTURE tb of tb_gpio_pad IS

    COMPONENT gpio_pad IS
    PORT(
        --INPUTS
	    clk,rst    :   IN STD_LOGIC;
	    gpio_dir :     IN STD_LOGIC;
	    gpio_en      : IN STD_LOGIC;
	    gpio_port_out: IN STD_LOGIC;
	    --OUTPUTS
	    gpio_port_in : OUT STD_LOGIC;
	    --INOUTS
	    gpio_pin:  INOUT STD_LOGIC
	);
	END COMPONENT;

    SIGNAL gpio_dir_s, gpio_en_s, gpio_port_out_s, gpio_pin_s, gpio_port_in_s: STD_LOGIC;

    CONSTANT step : TIME := 20ns;

BEGIN

    gpio: gpio_pad 
    PORT MAP(
        --INPUTS
	    clk => '0',
        rst => '0',
	    gpio_dir => gpio_dir_s,
	    gpio_en  => gpio_en_s,
	    gpio_port_out => gpio_port_out_s,
	    --OUTPUTS
	    gpio_port_in => gpio_port_in_s,
	    --INOUTS
	    gpio_pin => gpio_pin_s
    );

    sim: PROCESS
    BEGIN

        -- Initial values
        gpio_dir_s <= '0';
        gpio_en_s <= '0';
        gpio_port_out_s <= '0';
        gpio_pin_s <=  '1';
        WAIT FOR step;
        
               
        gpio_dir_s <= '0';
        gpio_en_s <= '0';
        gpio_port_out_s <= '1';
        WAIT FOR step;

        
        gpio_dir_s <= '1';
        gpio_en_s <= '0';
        gpio_port_out_s <= '0';
        gpio_pin_s <= 'Z';
        WAIT FOR step;
        
        gpio_dir_s <= '1';
        gpio_port_out_s <= '1';
        WAIT FOR step;

        --Output
        gpio_dir_s <= '1';
        gpio_en_s <= '1';
        gpio_port_out_s <= '1';
        gpio_pin_s <= '1';

        --Input 
        gpio_dir_s <= '0';
        gpio_en_s <= '1';
        gpio_port_out_s <= '1';
        WAIT;

    END PROCESS sim;


    



END ARCHITECTURE tb;
