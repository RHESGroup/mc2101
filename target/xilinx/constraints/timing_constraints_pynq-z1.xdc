#Timing constraints section
#Primary clocks
## Clock signal 50 MHz
#create_clock -period 20.000 -name main_clock [get_ports sys_clock]
#Generated clocks
#Virtual clocks
create_clock -period 20.000 -name VIRTUAL_clk_out1_clk_wiz_0 -waveform {0.000 10.000}

#Input delays
set_input_delay -clock [get_clocks VIRTUAL_clk_out1_clk_wiz_0] -min 2.000 [get_ports {gpio_pads_0[*]}]
set_input_delay -clock [get_clocks VIRTUAL_clk_out1_clk_wiz_0] -max 12.000 [get_ports {gpio_pads_0[*]}]

set_input_delay -clock [get_clocks VIRTUAL_clk_out1_clk_wiz_0] -min 2.000 [get_ports reset_rtl]
set_input_delay -clock [get_clocks VIRTUAL_clk_out1_clk_wiz_0] -max 9.000 [get_ports reset_rtl]

set_input_delay -clock [get_clocks VIRTUAL_clk_out1_clk_wiz_0] -min 2.000 [get_ports uart_rx_0]
set_input_delay -clock [get_clocks VIRTUAL_clk_out1_clk_wiz_0] -max 13.000 [get_ports uart_rx_0]

##Output delays
set_output_delay -clock [get_clocks VIRTUAL_clk_out1_clk_wiz_0] -min 4.000 [get_ports {gpio_pads_0[*]}]
set_output_delay -clock [get_clocks VIRTUAL_clk_out1_clk_wiz_0] -max 10.000 [get_ports {gpio_pads_0[*]}]

set_output_delay -clock [get_clocks VIRTUAL_clk_out1_clk_wiz_0] -min 3.000 [get_ports uart_tx_0]
set_output_delay -clock [get_clocks VIRTUAL_clk_out1_clk_wiz_0] -max 9.000 [get_ports uart_tx_0]

