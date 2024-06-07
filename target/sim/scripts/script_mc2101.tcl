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

#Signals related to memory wrapper
add_wave_group Mem_wrapper
add_wave -into {Mem_wrapper} {/tb_mc2101/microcontroller/MC2101_1/BRAM} 

add_wave_group -into {Mem_wrapper} {Controller}
add_wave -into {Controller} {/tb_mc2101/microcontroller/MC2101_1/BRAM/controller} 

run 1000ns
