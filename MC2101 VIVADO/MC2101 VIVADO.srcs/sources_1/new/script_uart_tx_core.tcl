#TCL script to create the environment to simulate the uartTX core
set sets [get_filesets -regexp "sim_[0-9]+"] ;# Search if there is any simulation set already created
if {[llength $set]} {
    puts "The simulation sets are: $sets ";
    set sim_set [lindex $sets 0] ;# We can simulate everything with only one simulation set 
    current_fileset -simset $sim_set; ;#Selection of the current simulation set
    set_property top tb_uart_tx_core $sim_set;
    set_property top_lib xil_defaultlib $sim_set;
    puts "The simulation uses : $sim_set";
} else {
    create_fileset -simset sim_1 ;#If there is no simulation set, create one 
    current_fileset -simset [get_filesets sim_1] ;#Selection of the current simulation set
    set_property top tb_uart_tx_core [get_filesets sim_1];
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


run 3000ns
