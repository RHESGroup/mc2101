--Copyright 1986-2022 Xilinx, Inc. All Rights Reserved.
--Copyright 2022-2023 Advanced Micro Devices, Inc. All Rights Reserved.
----------------------------------------------------------------------------------
--Tool Version: Vivado v.2023.1 (win64) Build 3865809 Sun May  7 15:05:29 MDT 2023
--Date        : Thu Apr 11 16:09:13 2024
--Host        : DESKTOP-PR463R7 running 64-bit major release  (build 9200)
--Command     : generate_target design1_wrapper.bd
--Design      : design1_wrapper
--Purpose     : IP block netlist
----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
library UNISIM;
use UNISIM.VCOMPONENTS.ALL;
use work.Constants.ALL;
entity mc2101_wrapper is
  port (
    gpio_pads_0 : inout STD_LOGIC_VECTOR ( 31 downto 0 );
    reset_rtl : in STD_LOGIC;
    sys_clock : in STD_LOGIC;
    uart_rx_0 : in STD_LOGIC;
    uart_tx_0 : out STD_LOGIC
  );


end mc2101_wrapper;

architecture STRUCTURE of mc2101_wrapper is

  SIGNAL sys_reset_n, sys_clock_n : STD_LOGIC;
  SIGNAL enable_s : STD_LOGIC;
  SIGNAL write_enable_s : STD_LOGIC_VECTOR(0 DOWNTO 0);
  SIGNAL data_to_BRAM_s : STD_LOGIC_VECTOR(dataWidthSRAM-1 DOWNTO 0);
  SIGNAL data_from_BRAM_s : STD_LOGIC_VECTOR(dataWidthSRAM-1 DOWNTO 0);
  SIGNAL address_bram_s : STD_LOGIC_VECTOR(Physical_size-1 DOWNTO 0);
  SIGNAL is_BRAM_busy_s : STD_LOGIC;
  SIGNAL rden : STD_LOGIC;
  SIGNAL wren : STD_LOGIC;
  
  SIGNAL wea_s : STD_LOGIC_VECTOR(0 DOWNTO 0);
  
  
 

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
  
  END COMPONENT  blk_mem_gen_0;
  
  COMPONENT mc2101 IS
  GENERIC( Physical_size     : INTEGER := Physical_size;
    	   busDataWidth      : INTEGER := dataWidth ;
		   busAddressWidth   : INTEGER := addressWidth
    );
	PORT(
	    sys_clk     : IN  STD_LOGIC;
	    sys_rst_n   : IN  STD_LOGIC;
	    gpio_pads   : INOUT STD_LOGIC_VECTOR(31 DOWNTO 0);
	    uart_rx     : IN  STD_LOGIC;
	    uart_tx     : OUT std_logic;
	    --Signals associated with the BRAM
        data_from_BRAM: IN STD_LOGIC_VECTOR(busDataWidth-1 DOWNTO 0);
	    data_to_BRAM  : OUT STD_LOGIC_VECTOR(busDataWidth-1 DOWNTO 0); 
	    address_bram  : OUT STD_LOGIC_VECTOR(Physical_size-1 DOWNTO 0);
	    memRead       : OUT STD_LOGIC;
	    memWrite      : OUT STD_LOGIC
	);
  END COMPONENT mc2101;


begin

  sys_reset_n <= NOT(reset_rtl);
  
  sys_clock_n <= NOT(sys_clock);
  

  wea_s <= (OTHERS => '0') WHEN wren ='0' ELSE (OTHERS => '1');

  bmg0 : blk_mem_gen_0 
    PORT MAP (
   
    --Port A(Port to write)
    ENA => wren,
    WEA => wea_s,
    ADDRA => address_bram_s,
    DINA => data_to_BRAM_s,
    CLKA => sys_clock,
    --Port B(Port to read)
    ENB => rden,
    ADDRB => address_bram_s,
    DOUTB => data_from_BRAM_s,
    CLKB => sys_clock_n
    );
    
    
  MC2101_1 : mc2101
  GENERIC MAP( Physical_size => Physical_size,
    	   busDataWidth => dataWidth, 
		   busAddressWidth => addressWidth
    )
	PORT MAP(
	    sys_clk => sys_clock,
	    sys_rst_n => sys_reset_n, 
	    gpio_pads => gpio_pads_0,
	    uart_rx => uart_rx_0,
	    uart_tx => uart_tx_0,
	    --Signals associated with the BRAM
	    data_from_BRAM => data_from_BRAM_s,
	    data_to_BRAM => data_to_BRAM_s,
	    address_bram => address_bram_s,
	    memRead => rden,
	    memWrite => wren
	    
	);

  


end STRUCTURE;
