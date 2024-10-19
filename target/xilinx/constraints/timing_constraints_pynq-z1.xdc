#Timing constraints section
#Primary clocks
## Clock signal 50 MHz
create_clock -name main_clock -period 20.000 [get_ports sys_clock]

#Virtual clocks

#Input delays
set_input_delay -clock [get_clocks {main_clock}] -min 6  [get_ports {gpio_pads_0[*]}]
set_input_delay -clock [get_clocks {main_clock}] -max 16 [get_ports {gpio_pads_0[*]}]

set_input_delay -clock [get_clocks {main_clock}] -min 6 [get_ports {reset_rtl}]
set_input_delay -clock [get_clocks {main_clock}] -max 16 [get_ports {reset_rtl}]

set_input_delay -clock [get_clocks {main_clock}] -min 4 [get_ports {uart_rx_0}]
set_input_delay -clock [get_clocks {main_clock}] -max 10 [get_ports {uart_rx_0}]

#Output delays
set_output_delay -clock [get_clocks {main_clock}] -min 6  [get_ports {gpio_pads_0[*]}]
set_output_delay -clock [get_clocks {main_clock}] -max 10 [get_ports {gpio_pads_0[*]}]

set_output_delay -clock [get_clocks {main_clock}] -min 4 [get_ports {uart_tx_0}]
set_output_delay -clock [get_clocks {main_clock}] -max 7 [get_ports {uart_tx_0}]





