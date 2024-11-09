set partNumber $::env(XILINX_PART)
set boardName  $::env(XILINX_BOARD)


set ipName clk_wiz_0

set current_directory [file normalize [pwd]]
puts $current_directory

create_project $ipName $current_directory/IP/ClkWizard -force -part $partNumber
set_property board_part $boardName [current_project]
set_property target_language VHDL [current_project]

create_ip -name clk_wiz -vendor xilinx.com -library ip -version 6.0 -module_name clk_wiz_0

set_property -dict [list \
  CONFIG.CLKIN1_JITTER_PS {80.0} \
  CONFIG.CLKOUT1_JITTER {143.688} \
  CONFIG.CLKOUT1_PHASE_ERROR {96.948} \
  CONFIG.CLKOUT1_REQUESTED_OUT_FREQ {50} \
  CONFIG.CLKOUT1_USED {true} \
  CONFIG.CLKOUT2_JITTER {143.688} \
  CONFIG.CLKOUT2_PHASE_ERROR {96.948} \
  CONFIG.CLKOUT2_REQUESTED_OUT_FREQ {50} \
  CONFIG.CLKOUT2_REQUESTED_PHASE {180} \
  CONFIG.CLKOUT2_USED {true} \
  CONFIG.CLK_IN1_BOARD_INTERFACE {sys_clock} \
  CONFIG.MMCM_CLKFBOUT_MULT_F {8.000} \
  CONFIG.MMCM_CLKIN1_PERIOD {8.000} \
  CONFIG.MMCM_CLKOUT0_DIVIDE_F {20.000} \
  CONFIG.MMCM_CLKOUT1_DIVIDE {20} \
  CONFIG.MMCM_CLKOUT1_PHASE {180.000} \
  CONFIG.NUM_OUT_CLKS {2} \
  CONFIG.PRIM_IN_FREQ {125.000} \
] [get_ips clk_wiz_0]

close_project