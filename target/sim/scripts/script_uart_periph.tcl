#TCL script to create the environment to simulate the uart peripheral core
set project_name mc2101
#Open the project only if it is not already running
if {[catch {current_project } result ]} {
puts "DEBUG: Project $projectName is not open"
open_project ${project_name}.xpr
}

set sets [get_filesets -regexp "sim_[0-9]+"] ;# Search if there is any simulation set already created
if {[llength $sets]} {
    puts "The simulation sets are: $sets ";
    set sim_set [lindex $sets 0] ;# We can simulate everything with only one simulation set 
    current_fileset -simset $sim_set; ;#Selection of the current simulation set
    set_property top tb_uart_periph $sim_set;
    set_property top_lib xil_defaultlib $sim_set;
    puts "The simulation uses : $sim_set";
} else {
    create_fileset -simset sim_1 ;#If there is no simulation set, create one 
    current_fileset -simset [get_filesets sim_1] ;#Selection of the current simulation set
    set_property top tb_uart_periph [get_filesets sim_1];
    set_property top_lib xil_defaultlib [get_filesets sim_1];
}

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

#Signals related to the Peripheral
add_wave_group Main_UART_peripheral_signals

add_wave_group -into {Main_UART_peripheral_signals} {Control_Registers}
add_wave -into {Control_Registers} {/tb_uart_periph/uart_peripheral/reg_IER}
add_wave -into {Control_Registers} {/tb_uart_periph/uart_peripheral/reg_ISR}
add_wave -into {Control_Registers} {/tb_uart_periph/uart_peripheral/reg_FCR}
add_wave -into {Control_Registers} {/tb_uart_periph/uart_peripheral/reg_LCR}
add_wave -into {Control_Registers} {/tb_uart_periph/uart_peripheral/reg_LSR}
add_wave -into {Control_Registers} {/tb_uart_periph/uart_peripheral/reg_DLL}
add_wave -into {Control_Registers} {/tb_uart_periph/uart_peripheral/reg_DLM}
add_wave -into {Control_Registers} {/tb_uart_periph/uart_peripheral/reg_MCR}
add_wave -into {Control_Registers} {/tb_uart_periph/uart_peripheral/reg_MSR}
add_wave -into {Control_Registers} {/tb_uart_periph/uart_peripheral/divisor}
add_wave -into {Control_Registers} {/tb_uart_periph/uart_peripheral/prescaler}

add_wave_group -into {Main_UART_peripheral_signals} {Control_Signals}
add_wave -into {Control_Signals} {/tb_uart_periph/uart_peripheral/read_IER}
add_wave -into {Control_Signals} {/tb_uart_periph/uart_peripheral/write_IER}
add_wave -into {Control_Signals} {/tb_uart_periph/uart_peripheral/read_ISR}
add_wave -into {Control_Signals} {/tb_uart_periph/uart_peripheral/write_FCR}
add_wave -into {Control_Signals} {/tb_uart_periph/uart_peripheral/read_LCR}
add_wave -into {Control_Signals} {/tb_uart_periph/uart_peripheral/write_LCR}
add_wave -into {Control_Signals} {/tb_uart_periph/uart_peripheral/read_LSR} 
add_wave -into {Control_Signals} {/tb_uart_periph/uart_peripheral/read_DLL}
add_wave -into {Control_Signals} {/tb_uart_periph/uart_peripheral/write_DLL}
add_wave -into {Control_Signals} {/tb_uart_periph/uart_peripheral/read_DLM}
add_wave -into {Control_Signals} {/tb_uart_periph/uart_peripheral/write_DLM} 
add_wave -into {Control_Signals} {/tb_uart_periph/uart_peripheral/write_THR} 
add_wave -into {Control_Signals} {/tb_uart_periph/uart_peripheral/read_RHR}
add_wave -into {Control_Signals} {/tb_uart_periph/uart_peripheral/tx_elements} 
add_wave -into {Control_Signals} {/tb_uart_periph/uart_peripheral/rx_elements} 
add_wave -into {Control_Signals} {/tb_uart_periph/uart_peripheral/input_rx}
add_wave -into {Control_Signals} {/tb_uart_periph/uart_peripheral/output_tx} 


#Signals related to the uart TX fifo 
add_wave_group UART_TXFIFO_signals
#Inputs
add_wave -into {UART_TXFIFO_signals} {/tb_uart_periph/uart_peripheral/U_TX_FIFO/clear} 
add_wave -into {UART_TXFIFO_signals} {/tb_uart_periph/uart_peripheral/U_TX_FIFO/data_in}
add_wave -into {UART_TXFIFO_signals} {/tb_uart_periph/uart_peripheral/U_TX_FIFO/read_request} 
add_wave -into {UART_TXFIFO_signals} {/tb_uart_periph/uart_peripheral/U_TX_FIFO/write_request} 
#Outputs
add_wave -into {UART_TXFIFO_signals} {/tb_uart_periph/uart_peripheral/U_TX_FIFO/QUEUE} 
add_wave -into {UART_TXFIFO_signals} {/tb_uart_periph/uart_peripheral/U_TX_FIFO/elements} 
add_wave -into {UART_TXFIFO_signals} {/tb_uart_periph/uart_peripheral/U_TX_FIFO/data_out}
add_wave -into {UART_TXFIFO_signals} {/tb_uart_periph/uart_peripheral/U_TX_FIFO/fifo_empty}  
add_wave -into {UART_TXFIFO_signals} {/tb_uart_periph/uart_peripheral/U_TX_FIFO/fifo_full} 




#Signals related to the uart TX
add_wave_group UART_TX_signals
#Inputs
add_wave -into {UART_TX_signals} {/tb_uart_periph/uart_peripheral/U_TX/divisor}
add_wave -into {UART_TX_signals} {/tb_uart_periph/uart_peripheral/U_TX/parity_bit_en}
add_wave -into {UART_TX_signals} {/tb_uart_periph/uart_peripheral/U_TX/parity_type}
add_wave -into {UART_TX_signals} {/tb_uart_periph/uart_peripheral/U_TX/data_width}
add_wave -into {UART_TX_signals} {/tb_uart_periph/uart_peripheral/U_TX/stop_bits}
add_wave -into {UART_TX_signals} {/tb_uart_periph/uart_peripheral/U_TX/tx_data_i}
add_wave -into {UART_TX_signals} {/tb_uart_periph/uart_peripheral/U_TX/tx_valid}
#Outputs
add_wave -into {UART_TX_signals} {/tb_uart_periph/uart_peripheral/U_TX/tx_ready}
add_wave -into {UART_TX_signals} {/tb_uart_periph/uart_peripheral/U_TX/tx_out}

#Others
add_wave -into {UART_TX_signals} {/tb_uart_periph/uart_peripheral/U_TX/current_state}  
add_wave -into {UART_TX_signals} {/tb_uart_periph/uart_peripheral/U_TX/next_state} 
add_wave -into {UART_TX_signals} {/tb_uart_periph/uart_peripheral/U_TX/reg_tx_data} 


#Signals related to the uart RX fifo
add_wave_group UART_RXFIFO_signals
#Inputs
add_wave -into {UART_RXFIFO_signals} {/tb_uart_periph/uart_peripheral/U_RX_FIFO/clear} 
add_wave -into {UART_RXFIFO_signals} {/tb_uart_periph/uart_peripheral/U_RX_FIFO/data_in}
add_wave -into {UART_RXFIFO_signals} {/tb_uart_periph/uart_peripheral/U_RX_FIFO/read_request} 
add_wave -into {UART_RXFIFO_signals} {/tb_uart_periph/uart_peripheral/U_RX_FIFO/write_request} 
#Outputs
add_wave -into {UART_RXFIFO_signals} {/tb_uart_periph/uart_peripheral/U_RX_FIFO/QUEUE} 
add_wave -into {UART_RXFIFO_signals} {/tb_uart_periph/uart_peripheral/U_RX_FIFO/elements} 
add_wave -into {UART_RXFIFO_signals} {/tb_uart_periph/uart_peripheral/U_RX_FIFO/data_out}
add_wave -into {UART_RXFIFO_signals} {/tb_uart_periph/uart_peripheral/U_RX_FIFO/fifo_empty}  
add_wave -into {UART_RXFIFO_signals} {/tb_uart_periph/uart_peripheral/U_RX_FIFO/fifo_full} 



#Signals related to the uart RX
add_wave_group UART_RX_signals
#Inputs
add_wave -into {UART_RX_signals} {/tb_uart_periph/uart_peripheral/U_RX/divisor}
add_wave -into {UART_RX_signals} {/tb_uart_periph/uart_peripheral/U_RX/parity_bit_en}
add_wave -into {UART_RX_signals} {/tb_uart_periph/uart_peripheral/U_RX/parity_type}
add_wave -into {UART_RX_signals} {/tb_uart_periph/uart_peripheral/U_RX/data_width}
add_wave -into {UART_RX_signals} {/tb_uart_periph/uart_peripheral/U_RX/stop_bits}
add_wave -into {UART_RX_signals} {/tb_uart_periph/uart_peripheral/U_RX/rx_in_async}
#Outputs
add_wave -into {UART_RX_signals} {/tb_uart_periph/uart_peripheral/U_RX/break_interrupt}
add_wave -into {UART_RX_signals} {/tb_uart_periph/uart_peripheral/U_RX/frame_error}
add_wave -into {UART_RX_signals} {/tb_uart_periph/uart_peripheral/U_RX/parity_error}
add_wave -into {UART_RX_signals} {/tb_uart_periph/uart_peripheral/U_RX/rx_data_buffer}
add_wave -into {UART_RX_signals} {/tb_uart_periph/uart_peripheral/U_RX/rx_valid}

#Others
add_wave -into {UART_RX_signals} {/tb_uart_periph/uart_peripheral/U_RX/current_state} 
add_wave -into {UART_RX_signals} {/tb_uart_periph/uart_peripheral/U_RX/next_state} 
add_wave -into {UART_RX_signals} {/tb_uart_periph/uart_peripheral/U_RX/rx_line_fall}
add_wave -into {UART_RX_signals} {/tb_uart_periph/uart_peripheral/U_RX/rx_line_sync} 
add_wave -into {UART_RX_signals} {/tb_uart_periph/uart_peripheral/U_RX/data_received}
add_wave -into {UART_RX_signals} {/tb_uart_periph/uart_peripheral/U_RX/read} 



#Signals related to the interrupt controller of uart 
add_wave_group UART_interruptcnt_signals
#Inputs
add_wave -into {UART_interruptcnt_signals} {/tb_uart_periph/uart_peripheral/U_IN_CTRL/IER}
add_wave -into {UART_interruptcnt_signals} {/tb_uart_periph/uart_peripheral/U_IN_CTRL/rx_fifo_trigger_lv}
add_wave -into {UART_interruptcnt_signals} {/tb_uart_periph/uart_peripheral/U_IN_CTRL/rx_elements}
add_wave -into {UART_interruptcnt_signals} {/tb_uart_periph/uart_peripheral/U_IN_CTRL/tx_elements}
add_wave -into {UART_interruptcnt_signals} {/tb_uart_periph/uart_peripheral/U_IN_CTRL/rx_line_error}
add_wave -into {UART_interruptcnt_signals} {/tb_uart_periph/uart_peripheral/U_IN_CTRL/interrupt_clear}
add_wave -into {UART_interruptcnt_signals} {/tb_uart_periph/uart_peripheral/U_IN_CTRL/char_timeout}
#Outputs
add_wave -into {UART_interruptcnt_signals} {/tb_uart_periph/uart_peripheral/U_IN_CTRL/interrupt}
add_wave -into {UART_interruptcnt_signals} {/tb_uart_periph/uart_peripheral/U_IN_CTRL/interrupt_isr_code}



run 1000ns
