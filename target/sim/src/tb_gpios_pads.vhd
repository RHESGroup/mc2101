LIBRARY IEEE;
LIBRARY STD;
USE IEEE.std_logic_1164.all;

ENTITY tb_gpio_pads IS
END ENTITY;

ARCHITECTURE behavioral OF tb_gpio_pads IS

    COMPONENT gpio_pads_if IS
        PORT(
            --INPUTS
            clk:            IN STD_LOGIC;
            rst:            IN STD_LOGIC;
            gpios_dir:      IN STD_LOGIC_VECTOR(31 DOWNTO 0);
            gpios_port_out: IN STD_LOGIC_VECTOR(31 DOWNTO 0);
            gpios_en      : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
            --OUTPUTS
            gpios_port_in : OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
            --INOUTS
	        gpios_pin:      INOUT STD_LOGIC_VECTOR(31 DOWNTO 0)
        );
    END COMPONENT;

    SIGNAL gpios_dir_s, gpios_port_out_s, gpios_en_s, gpios_pin_s, gpios_port_in_s: STD_LOGIC_VECTOR(31 DOWNTO 0);
    SIGNAL clk_s , rst_s: STD_LOGIC := '0';

    CONSTANT Clock_period : TIME := 20 ns;

    BEGIN

    -- Instantiate the GPIO_PAD component
    pio_pad: gpio_pads_if 
    PORT MAP (
        clk => clk_s,
        rst => rst_s,
        gpios_dir => gpios_dir_s,
        gpios_port_out =>  gpios_port_out_s,
        gpios_en => gpios_en_s,
        gpios_port_in => gpios_port_in_s,
        gpios_pin => gpios_pin_s
    );

    Clock_process : PROCESS
    BEGIN

        clk_s <= NOT clk_s;
        WAIT FOR Clock_period;

    END PROCESS Clock_process;

    Vector_process: PROCESS
    BEGIN 

        rst_s <= '1';
        gpios_en_s <= X"00000001";
        gpios_dir_s <= X"00000000"; --INPUTS all
        gpios_pin_s <= X"00000000"; 
        gpios_port_out_s <= X"00000001"; 
        WAIT FOR Clock_period;

        rst_s <= '0';
        WAIT FOR Clock_period;
        
        gpios_en_s <= X"00000003";
        gpios_dir_s <= X"00000002"; --INPUTS all except for GPIO1
        gpios_port_out_s <= X"00000001"; 
        gpios_pin_s <= X"0000000" & "00Z0"; 
        WAIT FOR Clock_period;
        
        gpios_en_s <= X"00000003";
        gpios_dir_s <= X"00000003"; --INPUTS all except for GPIO1
        gpios_port_out_s <= X"00000001"; 
        gpios_pin_s <= X"0000000" & "00ZZ"; 
        WAIT FOR Clock_period;
        
        gpios_en_s <= X"00000000"; ---all are deactivated
        WAIT;

    END PROCESS Vector_process;





END ARCHITECTURE;