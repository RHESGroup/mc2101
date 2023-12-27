#TCL script to create the environment to simulate the uartRX core
launch_simulation
set curr_wave [current_wave_config]
if { [string length $curr_wave] == 0 } {
    if { [llength [get_objects]] > 0} {
        add_wave /
        set_property needs_save false [current_wave_config]
    } else {
        send_msg_id Add_Wave-1 WARNING "No top level signals found. Simulator will start without a wave window. If you want to open a wave window go to 'File->New Waveform Configuration' or type 'create_wave_config' in the TCL console."
    }
 }
restart
add_wave {{/tb_uart_rx_core/uart_rx/sample_parity_bit_received}} 
add_wave {{/tb_uart_rx_core/uart_rx/rx_line_sync}}
add_wave {{/tb_uart_rx_core/uart_rx/current_data_bit}}
add_wave {{/tb_uart_rx_core/uart_rx/next_data_bit}} 
add_wave {{/tb_uart_rx_core/uart_rx/target_data_bits}} 
add_wave {{/tb_uart_rx_core/uart_rx/start_bit}} 
add_wave {{/tb_uart_rx_core/uart_rx/current_state}} 
add_wave {{/tb_uart_rx_core/uart_rx/next_state}} 
add_wave {{/tb_uart_rx_core/uart_rx/current_data}} 
add_wave {{/tb_uart_rx_core/uart_rx/next_data}} 
add_wave {{/tb_uart_rx_core/uart_rx/sample}} 

run 3000ns
