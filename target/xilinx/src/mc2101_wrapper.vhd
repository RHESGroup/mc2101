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
  component design1 is
  port (
    sys_clock : in STD_LOGIC;
    reset_rtl : in STD_LOGIC;
    gpio_pads_0 : inout STD_LOGIC_VECTOR ( 31 downto 0 );
    uart_tx_0 : out STD_LOGIC;
    uart_rx_0 : in STD_LOGIC
  );
  end component design1;
begin
design1_i: component design1
     port map (
      gpio_pads_0(31 downto 0) => gpio_pads_0(31 downto 0),
      reset_rtl => reset_rtl,
      sys_clock => sys_clock,
      uart_rx_0 => uart_rx_0,
      uart_tx_0 => uart_tx_0
    );
end STRUCTURE;
