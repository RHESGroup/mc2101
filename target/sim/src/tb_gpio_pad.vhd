LIBRARY IEEE;
LIBRARY STD;
USE IEEE.std_logic_1164.all;

ENTITY tb_gpio_pad IS
END ENTITY;

ARCHITECTURE behavioral OF tb_gpio_pad IS

    COMPONENT gpio_pad IS
        PORT (
            --INPUTS
            clk:           IN STD_LOGIC;
            rst:           IN STD_LOGIC;
            gpio_dir : IN STD_LOGIC;
            gpio_port_out: IN STD_LOGIC;
            gpio_en      : IN STD_LOGIC;
            --OUTPUTS
            gpio_port_in : OUT STD_LOGIC;
            --INOUTS
            gpio_pin:  INOUT STD_LOGIC
        );
    END COMPONENT;

    SIGNAL  rst_s, gpio_dir_s, gpio_port_out_s, gpio_en_s, gpio_pin_s, gpio_port_in_s: STD_LOGIC;
    SIGNAL clk_s : STD_LOGIC := '0';

    CONSTANT Clock_period : TIME := 20 ns;

    BEGIN

    -- Instantiate the GPIO_PAD component
    pio_pad: gpio_pad 
    PORT MAP (
        clk => clk_s,
        rst => rst_s,
        gpio_dir => gpio_dir_s,
        gpio_port_out =>  gpio_port_out_s,
        gpio_en => gpio_en_s,
        gpio_port_in => gpio_port_in_s,
        gpio_pin => gpio_pin_s
    );

    Clock_process : PROCESS
    BEGIN

        clk_s <= NOT clk_s;
        WAIT FOR Clock_period;

    END PROCESS Clock_process;

    Vector_process: PROCESS
    BEGIN 

        rst_s <= '1';
        gpio_en_s <= '1';
        gpio_dir_s <= '0'; --INPUT
        gpio_port_out_s <= '0';
        WAIT FOR Clock_period;

        rst_s <= '0';
        gpio_pin_s <= '0';
        WAIT FOR Clock_period;

        gpio_en_s <= '1';
        gpio_dir_s <= '1'; --OUTPUT
        gpio_port_out_s <= '0';
        gpio_pin_s <= 'Z';
        WAIT FOR Clock_period;


        gpio_en_s <= '1';
        gpio_dir_s <= '1'; --OUTPUT
        gpio_port_out_s <= '1';
        WAIT FOR Clock_period;
        
        gpio_en_s <= '0';
        gpio_dir_s <= '1'; --OUTPUT
        gpio_port_out_s <= '1';
        WAIT;

    END PROCESS Vector_process;





END ARCHITECTURE;