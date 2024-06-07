----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 06/04/2024 03:52:38 PM
-- Design Name: 
-- Module Name: tb_bram - Behavioral
-- Project Name: 
-- Target Devices: 
-- Tool Versions: 
-- Description: 
-- 
-- Dependencies: 
-- 
-- Revision:
-- Revision 0.01 - File Created
-- Additional Comments:
-- 
----------------------------------------------------------------------------------


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity tb_bram is
--  Port ( );
end tb_bram;

architecture Behavioral of tb_bram is

  COMPONENT blk_mem_gen_0 IS
  PORT (
    --Port A
    ENA        : IN STD_LOGIC;  --opt port
    WEA        : IN STD_LOGIC_VECTOR(0 DOWNTO 0);
    ADDRA      : IN STD_LOGIC_VECTOR(13  DOWNTO 0);
    DINA       : IN STD_LOGIC_VECTOR(7 DOWNTO 0);
    CLKA       : IN STD_LOGIC;
    --Port B
    ENB        : IN STD_LOGIC;  --opt port
    ADDRB      : IN STD_LOGIC_VECTOR(13  DOWNTO 0);
    DOUTB      : OUT STD_LOGIC_VECTOR(7 DOWNTO 0);
    CLKB       : IN STD_LOGIC
  );

  END COMPONENT blk_mem_gen_0;
  
  CONSTANT clk_period : TIME := 20ns;
  
  SIGNAL clk_s, nclk_s, wren, rden, rst_busyA, rst_busyB:  STD_LOGIC := '0';
  SIGNAL address_s :  STD_LOGIC_VECTOR(13 DOWNTO 0);
  SIGNAL data: STD_LOGIC_VECTOR(7 DOWNTO 0);
  SIGNAL output: STD_LOGIC_VECTOR(7 DOWNTO 0);
  SIGNAL wea_s : STD_LOGIC_VECTOR(0 DOWNTO 0);
  

  
  

begin


Clock_process : PROCESS
BEGIN
    clk_s <= '0';
    WAIT FOR clk_period/2;
    clk_s<= '1';
    WAIT FOR clk_period/2;
END PROCESS;

nclk_s <= NOT(clk_s);

bram: blk_mem_gen_0 
PORT MAP(
    --Port A
    ENA => wren,
    WEA => wea_s,
    ADDRA => address_s,
    DINA => data,
    CLKA => nclk_s,
    --Port B
    ENB => rden,
    ADDRB => address_s,
    DOUTB => output,
    CLKB => clk_s

);

TEST: PROCESS
BEGIN
    --Initial states
    rden <= '1';
    wren <= '0';
    wea_s <= (OTHERS => '0');
    address_s <= "00000000000000";
    data <= X"00";
    WAIT FOR clk_period;
    
    --Read 1º memory position
    rden <= '1';
    address_s <= "00000000000000";
    WAIT FOR clk_period;
    
    --Read 2º memory position
    rden <= '1';
    address_s <= "00000000000001";
    WAIT FOR clk_period;
    
    --Read 3º memory position
    rden <= '1';
    address_s <= "00000000000010";
    WAIT FOR clk_period;
    
    rden <= '0';
    
    
    --Write 1ª mem position
    wren <= '1';
    address_s <= "00000000000000";
    data <= X"FF";
    WAIT FOR clk_period;
    
    
    --Write 2ª mem position
    wren <= '1';
    address_s <= "00000000000001";
    data <= X"01";
    WAIT FOR clk_period;
    
    
    --Write 3ª mem position
    wren <= '1';
    address_s <= "00000000000010";
    data <= X"11";
    WAIT FOR clk_period;
    
    
    --Write 4ª mem position
    wren <= '1';
    address_s <= "00000000000011";
    data <= X"AB";
    WAIT FOR clk_period;
    
    wren <='0';
    
    --Read 4º memory position
    rden <= '1';
    address_s <= "00000000000011";
    WAIT FOR clk_period;
    WAIT;   
END PROCESS;



end Behavioral;
