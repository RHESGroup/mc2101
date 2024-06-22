#TCL script to create the environment to simulate the mc2101
#set project_name mc2101
#open_project ${project_name}.xpr

set sets [get_filesets -regexp "sim_[0-9]+"] ;# Search if there is any simulation set already created
if {[llength $sets]} {
    puts "The simulation sets are: $sets ";
    set sim_set [lindex $sets 0] ;# We can simulate everything with only one simulation set 
    current_fileset -simset $sim_set; ;#Selection of the current simulation set
    set_property top tb_mc2101 $sim_set;
    set_property top_lib xil_defaultlib $sim_set;
    puts "The simulation uses : $sim_set";
} else {
    create_fileset -simset sim_1 ;#If there is no simulation set, create one 
    current_fileset -simset [get_filesets sim_1] ;#Selection of the current simulation set
    set_property top tb_mc2101 [get_filesets sim_1];
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


#Signals related to the BRAM
add_wave_group BRAM
add_wave -into {BRAM}  {/tb_mc2101/microcontroller/bmg0/clka} 
add_wave -into {BRAM}  {/tb_mc2101/microcontroller/bmg0/clkb}
add_wave -into {BRAM}  {/tb_mc2101/microcontroller/bmg0/ena}
add_wave -into {BRAM}  {/tb_mc2101/microcontroller/bmg0/enb}
add_wave -into {BRAM}  {/tb_mc2101/microcontroller/bmg0/wea}
add_wave -into {BRAM}  {/tb_mc2101/microcontroller/bmg0/addra}
add_wave -into {BRAM}  {/tb_mc2101/microcontroller/bmg0/addrb}
add_wave -into {BRAM}  {/tb_mc2101/microcontroller/bmg0/dina}
add_wave -into {BRAM}  {/tb_mc2101/microcontroller/bmg0/doutb}


#Signals related to the Datapath core
add_wave_group CORE_datapath
add_wave -into {CORE_datapath} {/tb_mc2101/microcontroller/MC2101_1/AFTAB/core/datapathAFTAB} 

#Signals related to the Controller core
add_wave_group CORE_controller
add_wave -into {CORE_controller} {/tb_mc2101/microcontroller/MC2101_1/AFTAB/core/controllerAFTAB} 

#Signals related to the Memory wrapper
add_wave_group Mem_wrapper
add_wave -into {Mem_wrapper} {/tb_mc2101/microcontroller/MC2101_1/BRAM} 

add_wave_group -into {Mem_wrapper} {Controller}
add_wave -into {Controller} {/tb_mc2101/microcontroller/MC2101_1/BRAM/controller} 

#Signals related to the UART peripheral


#Signals related to the Peripheral
add_wave_group UART

add_wave -into {UART} {/tb_mc2101/microcontroller/MC2101_1/UART/hselx}
add_wave -into {UART} {/tb_mc2101/microcontroller/MC2101_1/UART/hwrite}
add_wave -into {UART} {/tb_mc2101/microcontroller/MC2101_1/UART/hwrdata} 
add_wave -into {UART} {/tb_mc2101/microcontroller/MC2101_1/UART/haddr}
add_wave -into {UART} {/tb_mc2101/microcontroller/MC2101_1/UART/uart_periph/address}
add_wave -into {UART} {/tb_mc2101/microcontroller/MC2101_1/UART/uart_periph/busDataIn}
add_wave -into {UART} {/tb_mc2101/microcontroller/MC2101_1/UART/uart_periph/busDataOut} 


add_wave_group -into {UART} {Control_Registers}
add_wave -into {Control_Registers} {/tb_mc2101/microcontroller/MC2101_1/UART/uart_periph/reg_IER}
add_wave -into {Control_Registers} {/tb_mc2101/microcontroller/MC2101_1/UART/uart_periph/reg_ISR}
add_wave -into {Control_Registers} {/tb_mc2101/microcontroller/MC2101_1/UART/uart_periph/reg_FCR}
add_wave -into {Control_Registers} {/tb_mc2101/microcontroller/MC2101_1/UART/uart_periph/reg_LCR}
add_wave -into {Control_Registers} {/tb_mc2101/microcontroller/MC2101_1/UART/uart_periph/reg_LSR}
add_wave -into {Control_Registers} {/tb_mc2101/microcontroller/MC2101_1/UART/uart_periph/reg_DLL}
add_wave -into {Control_Registers} {/tb_mc2101/microcontroller/MC2101_1/UART/uart_periph/reg_DLM}
add_wave -into {Control_Registers} {/tb_mc2101/microcontroller/MC2101_1/UART/uart_periph/reg_MCR}
add_wave -into {Control_Registers} {/tb_mc2101/microcontroller/MC2101_1/UART/uart_periph/reg_MSR}
add_wave -into {Control_Registers} {/tb_mc2101/microcontroller/MC2101_1/UART/uart_periph/divisor}
add_wave -into {Control_Registers} {/tb_mc2101/microcontroller/MC2101_1/UART/uart_periph/prescaler}


add_wave_group -into {UART} {Control_Signals}
add_wave -into {Control_Signals} {/tb_mc2101/microcontroller/MC2101_1/UART/uart_periph/read_IER}
add_wave -into {Control_Signals} {/tb_mc2101/microcontroller/MC2101_1/UART/uart_periph/write_IER}
add_wave -into {Control_Signals} {/tb_mc2101/microcontroller/MC2101_1/UART/uart_periph/read_ISR}
add_wave -into {Control_Signals} {/tb_mc2101/microcontroller/MC2101_1/UART/uart_periph/write_FCR}
add_wave -into {Control_Signals} {/tb_mc2101/microcontroller/MC2101_1/UART/uart_periph/read_LCR}
add_wave -into {Control_Signals} {/tb_mc2101/microcontroller/MC2101_1/UART/uart_periph/write_LCR}
add_wave -into {Control_Signals} {/tb_mc2101/microcontroller/MC2101_1/UART/uart_periph/read_LSR} 
add_wave -into {Control_Signals} {/tb_mc2101/microcontroller/MC2101_1/UART/uart_periph/read_DLL}
add_wave -into {Control_Signals} {/tb_mc2101/microcontroller/MC2101_1/UART/uart_periph/write_DLL}
add_wave -into {Control_Signals} {/tb_mc2101/microcontroller/MC2101_1/UART/uart_periph/read_DLM}
add_wave -into {Control_Signals} {/tb_mc2101/microcontroller/MC2101_1/UART/uart_periph/write_DLM} 
add_wave -into {Control_Signals} {/tb_mc2101/microcontroller/MC2101_1/UART/uart_periph/write_THR} 
add_wave -into {Control_Signals} {/tb_mc2101/microcontroller/MC2101_1/UART/uart_periph/read_RHR}
add_wave -into {Control_Signals} {/tb_mc2101/microcontroller/MC2101_1/UART/uart_periph/tx_elements} 
add_wave -into {Control_Signals} {/tb_mc2101/microcontroller/MC2101_1/UART/uart_periph/rx_elements} 
add_wave -into {Control_Signals} {/tb_mc2101/microcontroller/MC2101_1/UART/uart_periph/input_rx}
add_wave -into {Control_Signals} {/tb_mc2101/microcontroller/MC2101_1/UART/uart_periph/output_tx} 


#Signals related to the uart TX fifo 
add_wave_group -into {UART} {UART_TXFIFO_signals}
#Inputs
add_wave -into {UART_TXFIFO_signals} {/tb_mc2101/microcontroller/MC2101_1/UART/uart_periph/U_TX_FIFO/clear} 
add_wave -into {UART_TXFIFO_signals} {/tb_mc2101/microcontroller/MC2101_1/UART/uart_periph/U_TX_FIFO/data_in}
add_wave -into {UART_TXFIFO_signals} {/tb_mc2101/microcontroller/MC2101_1/UART/uart_periph/U_TX_FIFO/read_request} 
add_wave -into {UART_TXFIFO_signals} {/tb_mc2101/microcontroller/MC2101_1/UART/uart_periph/U_TX_FIFO/write_request} 
#Outputs
add_wave -into {UART_TXFIFO_signals} {/tb_mc2101/microcontroller/MC2101_1/UART/uart_periph/U_TX_FIFO/QUEUE} 
add_wave -into {UART_TXFIFO_signals} {/tb_mc2101/microcontroller/MC2101_1/UART/uart_periph/U_TX_FIFO/elements} 
add_wave -into {UART_TXFIFO_signals} {/tb_mc2101/microcontroller/MC2101_1/UART/uart_periph/U_TX_FIFO/data_out}
add_wave -into {UART_TXFIFO_signals} {/tb_mc2101/microcontroller/MC2101_1/UART/uart_periph/U_TX_FIFO/fifo_empty}  
add_wave -into {UART_TXFIFO_signals} {/tb_mc2101/microcontroller/MC2101_1/UART/uart_periph/U_TX_FIFO/fifo_full} 




#Signals related to the uart TX
add_wave_group -into {UART} {UART_TX_signals}
#Inputs
add_wave -into {UART_TX_signals} {/tb_mc2101/microcontroller/MC2101_1/UART/uart_periph/U_TX/divisor}
add_wave -into {UART_TX_signals} {/tb_mc2101/microcontroller/MC2101_1/UART/uart_periph/U_TX/parity_bit_en}
add_wave -into {UART_TX_signals} {/tb_mc2101/microcontroller/MC2101_1/UART/uart_periph/U_TX/parity_type}
add_wave -into {UART_TX_signals} {/tb_mc2101/microcontroller/MC2101_1/UART/uart_periph/U_TX/data_width}
add_wave -into {UART_TX_signals} {/tb_mc2101/microcontroller/MC2101_1/UART/uart_periph/U_TX/stop_bits}
add_wave -into {UART_TX_signals} {/tb_mc2101/microcontroller/MC2101_1/UART/uart_periph/U_TX/tx_data_i}
add_wave -into {UART_TX_signals} {/tb_mc2101/microcontroller/MC2101_1/UART/uart_periph/U_TX/tx_valid}
#Outputs
add_wave -into {UART_TX_signals} {/tb_mc2101/microcontroller/MC2101_1/UART/uart_periph/U_TX/tx_ready}
add_wave -into {UART_TX_signals} {/tb_mc2101/microcontroller/MC2101_1/UART/uart_periph/U_TX/tx_out}

#Others
add_wave -into {UART_TX_signals} {/tb_mc2101/microcontroller/MC2101_1/UART/uart_periph/U_TX/current_state}  
add_wave -into {UART_TX_signals} {/tb_mc2101/microcontroller/MC2101_1/UART/uart_periph/U_TX/next_state} 
add_wave -into {UART_TX_signals} {/tb_mc2101/microcontroller/MC2101_1/UART/uart_periph/U_TX/reg_tx_data} 
add_wave -into {UART_TX_signals} {/tb_mc2101/microcontroller/MC2101_1/UART/uart_periph/U_TX/bit_done}
add_wave -into {UART_TX_signals} {/tb_mc2101/microcontroller/MC2101_1/UART/uart_periph/U_TX/sample_data_in}


#Signals related to the uart RX fifo
add_wave_group -into {UART} {UART_RXFIFO_signals}
#Inputs
add_wave -into {UART_RXFIFO_signals} {/tb_mc2101/microcontroller/MC2101_1/UART/uart_periph/U_RX_FIFO/clear} 
add_wave -into {UART_RXFIFO_signals} {/tb_mc2101/microcontroller/MC2101_1/UART/uart_periph/U_RX_FIFO/data_in}
add_wave -into {UART_RXFIFO_signals} {/tb_mc2101/microcontroller/MC2101_1/UART/uart_periph/U_RX_FIFO/read_request} 
add_wave -into {UART_RXFIFO_signals} {/tb_mc2101/microcontroller/MC2101_1/UART/uart_periph/U_RX_FIFO/write_request} 
#Outputs
add_wave -into {UART_RXFIFO_signals} {/tb_mc2101/microcontroller/MC2101_1/UART/uart_periph/U_RX_FIFO/QUEUE} 
add_wave -into {UART_RXFIFO_signals} {/tb_mc2101/microcontroller/MC2101_1/UART/uart_periph/U_RX_FIFO/elements} 
add_wave -into {UART_RXFIFO_signals} {/tb_mc2101/microcontroller/MC2101_1/UART/uart_periph/U_RX_FIFO/data_out}
add_wave -into {UART_RXFIFO_signals} {/tb_mc2101/microcontroller/MC2101_1/UART/uart_periph/U_RX_FIFO/fifo_empty}  
add_wave -into {UART_RXFIFO_signals} {/tb_mc2101/microcontroller/MC2101_1/UART/uart_periph/U_RX_FIFO/fifo_full} 



#Signals related to the uart RX
add_wave_group -into {UART} {UART_RX_signals}
#Inputs
add_wave -into {UART_RX_signals} {/tb_mc2101/microcontroller/MC2101_1/UART/uart_periph/U_RX/divisor}
add_wave -into {UART_RX_signals} {/tb_mc2101/microcontroller/MC2101_1/UART/uart_periph/U_RX/parity_bit_en}
add_wave -into {UART_RX_signals} {/tb_mc2101/microcontroller/MC2101_1/UART/uart_periph/U_RX/parity_type}
add_wave -into {UART_RX_signals} {/tb_mc2101/microcontroller/MC2101_1/UART/uart_periph/U_RX/data_width}
add_wave -into {UART_RX_signals} {/tb_mc2101/microcontroller/MC2101_1/UART/uart_periph/U_RX/stop_bits}
add_wave -into {UART_RX_signals} {/tb_mc2101/microcontroller/MC2101_1/UART/uart_periph/U_RX/rx_in_async}
#Outputs
add_wave -into {UART_RX_signals} {/tb_mc2101/microcontroller/MC2101_1/UART/uart_periph/U_RX/break_interrupt}
add_wave -into {UART_RX_signals} {/tb_mc2101/microcontroller/MC2101_1/UART/uart_periph/U_RX/frame_error}
add_wave -into {UART_RX_signals} {/tb_mc2101/microcontroller/MC2101_1/UART/uart_periph/U_RX/parity_error}
add_wave -into {UART_RX_signals} {/tb_mc2101/microcontroller/MC2101_1/UART/uart_periph/U_RX/rx_data_buffer}
add_wave -into {UART_RX_signals} {/tb_mc2101/microcontroller/MC2101_1/UART/uart_periph/U_RX/rx_valid}

#Others
add_wave -into {UART_RX_signals} {/tb_mc2101/microcontroller/MC2101_1/UART/uart_periph/U_RX/current_state} 
add_wave -into {UART_RX_signals} {/tb_mc2101/microcontroller/MC2101_1/UART/uart_periph/U_RX/next_state} 
add_wave -into {UART_RX_signals} {/tb_mc2101/microcontroller/MC2101_1/UART/uart_periph/U_RX/rx_line_fall}
add_wave -into {UART_RX_signals} {/tb_mc2101/microcontroller/MC2101_1/UART/uart_periph/U_RX/rx_line_sync} 
add_wave -into {UART_RX_signals} {/tb_mc2101/microcontroller/MC2101_1/UART/uart_periph/U_RX/data_received}
add_wave -into {UART_RX_signals} {/tb_mc2101/microcontroller/MC2101_1/UART/uart_periph/U_RX/read} 



#Signals related to the interrupt controller of uart 
add_wave_group -into {UART} {UART_interruptcnt_signals}
#Inputs
add_wave -into {UART_interruptcnt_signals} {/tb_mc2101/microcontroller/MC2101_1/UART/uart_periph/U_IN_CTRL/IER}
add_wave -into {UART_interruptcnt_signals} {/tb_mc2101/microcontroller/MC2101_1/UART/uart_periph/U_IN_CTRL/rx_fifo_trigger_lv}
add_wave -into {UART_interruptcnt_signals} {/tb_mc2101/microcontroller/MC2101_1/UART/uart_periph/U_IN_CTRL/rx_elements}
add_wave -into {UART_interruptcnt_signals} {/tb_mc2101/microcontroller/MC2101_1/UART/uart_periph/U_IN_CTRL/tx_elements}
add_wave -into {UART_interruptcnt_signals} {/tb_mc2101/microcontroller/MC2101_1/UART/uart_periph/U_IN_CTRL/rx_line_error}
add_wave -into {UART_interruptcnt_signals} {/tb_mc2101/microcontroller/MC2101_1/UART/uart_periph/U_IN_CTRL/interrupt_clear}
add_wave -into {UART_interruptcnt_signals} {/tb_mc2101/microcontroller/MC2101_1/UART/uart_periph/U_IN_CTRL/char_timeout}
#Outputs
add_wave -into {UART_interruptcnt_signals} {/tb_mc2101/microcontroller/MC2101_1/UART/uart_periph/U_IN_CTRL/interrupt}
add_wave -into {UART_interruptcnt_signals} {/tb_mc2101/microcontroller/MC2101_1/UART/uart_periph/U_IN_CTRL/interrupt_isr_code}


run 1 ms