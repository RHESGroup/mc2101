--Copyright 1986-2022 Xilinx, Inc. All Rights Reserved.
--Copyright 2022-2023 Advanced Micro Devices, Inc. All Rights Reserved.
----------------------------------------------------------------------------------
--Tool Version: Vivado v.2023.1 (win64) Build 3865809 Sun May  7 15:05:29 MDT 2023
--Date        : Thu Apr 11 16:09:13 2024
--Host        : DESKTOP-PR463R7 running 64-bit major release  (build 9200)
--Command     : generate_target design1.bd
--Design      : design1
--Purpose     : IP block netlist
----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
library UNISIM;
use UNISIM.VCOMPONENTS.ALL;
entity design1 is
  port (
    gpio_pads_0 : inout STD_LOGIC_VECTOR ( 31 downto 0 );
    reset_rtl : in STD_LOGIC;
    sys_clock : in STD_LOGIC;
    uart_rx_0 : in STD_LOGIC;
    uart_tx_0 : out STD_LOGIC
  );
  attribute core_generation_info : string;
  attribute core_generation_info of design1 : entity is "design1,IP_Integrator,{x_ipVendor=xilinx.com,x_ipLibrary=BlockDiagram,x_ipName=design1,x_ipVersion=1.00.a,x_ipLanguage=VHDL,numBlks=3,numReposBlks=3,numNonXlnxBlks=0,numHierBlks=0,maxHierDepth=0,numSysgenBlks=0,numHlsBlks=0,numHdlrefBlks=1,numPkgbdBlks=0,bdsource=USER,da_board_cnt=5,da_clkrst_cnt=4,synth_mode=OOC_per_IP}";
  attribute hw_handoff : string;
  attribute hw_handoff of design1 : entity is "design1.hwdef";
end design1;

architecture STRUCTURE of design1 is
  component design1_blk_mem_gen_0_0 is
  port (
    clka : in STD_LOGIC;
    rsta : in STD_LOGIC;
    ena : in STD_LOGIC;
    wea : in STD_LOGIC_VECTOR ( 0 to 0 );
    addra : in STD_LOGIC_VECTOR ( 13 downto 0 );
    dina : in STD_LOGIC_VECTOR ( 7 downto 0 );
    douta : out STD_LOGIC_VECTOR ( 7 downto 0 );
    rsta_busy : out STD_LOGIC
  );
  end component design1_blk_mem_gen_0_0;
  component design1_rst_clk_wiz_100M_0 is
  port (
    slowest_sync_clk : in STD_LOGIC;
    ext_reset_in : in STD_LOGIC;
    aux_reset_in : in STD_LOGIC;
    mb_debug_sys_rst : in STD_LOGIC;
    dcm_locked : in STD_LOGIC;
    mb_reset : out STD_LOGIC;
    bus_struct_reset : out STD_LOGIC_VECTOR ( 0 to 0 );
    peripheral_reset : out STD_LOGIC_VECTOR ( 0 to 0 );
    interconnect_aresetn : out STD_LOGIC_VECTOR ( 0 to 0 );
    peripheral_aresetn : out STD_LOGIC_VECTOR ( 0 to 0 )
  );
  end component design1_rst_clk_wiz_100M_0;
  component design1_mc2101_0_0 is
  port (
    sys_clk : in STD_LOGIC;
    sys_rst_n : in STD_LOGIC;
    gpio_pads : inout STD_LOGIC_VECTOR ( 31 downto 0 );
    uart_rx : in STD_LOGIC;
    uart_tx : out STD_LOGIC;
    address_bram : out STD_LOGIC_VECTOR ( 13 downto 0 );
    write_enable : out STD_LOGIC;
    enable : out STD_LOGIC;
    data_to_BRAM : out STD_LOGIC_VECTOR ( 7 downto 0 );
    data_from_BRAM : in STD_LOGIC_VECTOR ( 7 downto 0 );
    is_BRAM_busy : in STD_LOGIC
  );
  end component design1_mc2101_0_0;
  signal Net : STD_LOGIC_VECTOR ( 31 downto 0 );
  signal blk_mem_gen_0_douta : STD_LOGIC_VECTOR ( 7 downto 0 );
  signal blk_mem_gen_0_rsta_busy : STD_LOGIC;
  signal clk_wiz_clk_out1 : STD_LOGIC;
  signal mc2101_0_address_bram : STD_LOGIC_VECTOR ( 13 downto 0 );
  signal mc2101_0_data_to_BRAM : STD_LOGIC_VECTOR ( 7 downto 0 );
  signal mc2101_0_enable : STD_LOGIC;
  signal mc2101_0_uart_tx : STD_LOGIC;
  signal mc2101_0_write_enable : STD_LOGIC;
  signal reset_rtl_1 : STD_LOGIC;
  signal rst_clk_wiz_100M_peripheral_aresetn : STD_LOGIC_VECTOR ( 0 to 0 );
  signal uart_rx_0_1 : STD_LOGIC;
  signal NLW_rst_clk_wiz_100M_mb_reset_UNCONNECTED : STD_LOGIC;
  signal NLW_rst_clk_wiz_100M_bus_struct_reset_UNCONNECTED : STD_LOGIC_VECTOR ( 0 to 0 );
  signal NLW_rst_clk_wiz_100M_interconnect_aresetn_UNCONNECTED : STD_LOGIC_VECTOR ( 0 to 0 );
  signal NLW_rst_clk_wiz_100M_peripheral_reset_UNCONNECTED : STD_LOGIC_VECTOR ( 0 to 0 );
  attribute x_interface_info : string;
  attribute x_interface_info of reset_rtl : signal is "xilinx.com:signal:reset:1.0 RST.RESET_RTL RST";
  attribute x_interface_parameter : string;
  attribute x_interface_parameter of reset_rtl : signal is "XIL_INTERFACENAME RST.RESET_RTL, INSERT_VIP 0, POLARITY ACTIVE_HIGH";
  attribute x_interface_info of sys_clock : signal is "xilinx.com:signal:clock:1.0 CLK.SYS_CLOCK CLK";
  attribute x_interface_parameter of sys_clock : signal is "XIL_INTERFACENAME CLK.SYS_CLOCK, CLK_DOMAIN design1_sys_clock, FREQ_HZ 125000000, FREQ_TOLERANCE_HZ 0, INSERT_VIP 0, PHASE 0.0";
begin
  clk_wiz_clk_out1 <= sys_clock;
  reset_rtl_1 <= reset_rtl;
  uart_rx_0_1 <= uart_rx_0;
  uart_tx_0 <= mc2101_0_uart_tx;
blk_mem_gen_0: component design1_blk_mem_gen_0_0
     port map (
      addra(13 downto 0) => mc2101_0_address_bram(13 downto 0),
      clka => '0',
      dina(7 downto 0) => mc2101_0_data_to_BRAM(7 downto 0),
      douta(7 downto 0) => blk_mem_gen_0_douta(7 downto 0),
      ena => mc2101_0_enable,
      rsta => '0',
      rsta_busy => blk_mem_gen_0_rsta_busy,
      wea(0) => mc2101_0_write_enable
    );
mc2101_0: component design1_mc2101_0_0
     port map (
      address_bram(13 downto 0) => mc2101_0_address_bram(13 downto 0),
      data_from_BRAM(7 downto 0) => blk_mem_gen_0_douta(7 downto 0),
      data_to_BRAM(7 downto 0) => mc2101_0_data_to_BRAM(7 downto 0),
      enable => mc2101_0_enable,
      gpio_pads(31 downto 0) => gpio_pads_0(31 downto 0),
      is_BRAM_busy => blk_mem_gen_0_rsta_busy,
      sys_clk => clk_wiz_clk_out1,
      sys_rst_n => rst_clk_wiz_100M_peripheral_aresetn(0),
      uart_rx => uart_rx_0_1,
      uart_tx => mc2101_0_uart_tx,
      write_enable => mc2101_0_write_enable
    );
rst_clk_wiz_100M: component design1_rst_clk_wiz_100M_0
     port map (
      aux_reset_in => '1',
      bus_struct_reset(0) => NLW_rst_clk_wiz_100M_bus_struct_reset_UNCONNECTED(0),
      dcm_locked => '1',
      ext_reset_in => reset_rtl_1,
      interconnect_aresetn(0) => NLW_rst_clk_wiz_100M_interconnect_aresetn_UNCONNECTED(0),
      mb_debug_sys_rst => '0',
      mb_reset => NLW_rst_clk_wiz_100M_mb_reset_UNCONNECTED,
      peripheral_aresetn(0) => rst_clk_wiz_100M_peripheral_aresetn(0),
      peripheral_reset(0) => NLW_rst_clk_wiz_100M_peripheral_reset_UNCONNECTED(0),
      slowest_sync_clk => clk_wiz_clk_out1
    );
end STRUCTURE;
