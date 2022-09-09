
# **************************************************************************************
#	Filename:	synthesis.tcl
#	Project:	CNL_RISC-V
#  	Version:	1.0
#	History:
#	Date:		9 Sep 2022
#
# Copyright (C) 2022 CINI Cybersecurity National Laboratory
#
# This source file may be used and distributed without
# restriction provided that this copyright statement is not
# removed from the file and that any derivative work contains
# the original copyright notice and the associated disclaimer.
#
# This source file is free software; you can redistribute it
# and/or modify it under the terms of the GNU Lesser General
# Public License as published by the Free Software Foundation;
# either version 3.0 of the License, or (at your option) any
# later version.
#
# This source is distributed in the hope that it will be
# useful, but WITHOUT ANY WARRANTY; without even the implied
# warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR
# PURPOSE. See the GNU Lesser General Public License for more
# details.
#
# You should have received a copy of the GNU Lesser General
# Public License along with this source; if not, download it
# from https://www.gnu.org/licenses/lgpl-3.0.txt
#
# **************************************************************************************
#
#	File content description:
#	#quartus synthesis flow
#	#hdl compile -> hdl syn -> place & route -> static timing analysis -> programmer 
#
# **************************************************************************************

set project_name "mc2101"
set make_assignment 1
set close_project 0
set RTL "../rtl"
set IPS "../ips/aftab"
set FPGA_IPS "./ips/altera_mem_16384x8_dp"
set SDC_FILE "mc2101.sdc"

#ips components (AFTAB)
set SRC_IPS_COMPONENTS " \
    $IPS/aftab_datapath/aftab_register.vhd \
    $IPS/aftab_datapath/aftab_multiplexer.vhd \
    $IPS/aftab_datapath/aftab_comparator.vhd \
    $IPS/aftab_datapath/aftab_counter.vhd \
    $IPS/aftab_datapath/aftab_isseu.vhd \
    $IPS/aftab_datapath/aftab_full_adder.vhd \
    $IPS/aftab_datapath/aftab_half_adder.vhd \
    $IPS/aftab_datapath/aftab_one_bit_register.vhd \
    $IPS/aftab_datapath/aftab_opt_adder.vhd \
    $IPS/aftab_datapath/aftab_adder.vhd \
    $IPS/aftab_datapath/aftab_adder_subtractor.vhd \
    $IPS/aftab_datapath/aftab_decoder.vhd \
    $IPS/aftab_datapath/aftab_barrel_shifter.vhd \
    $IPS/aftab_datapath/aftab_llu.vhd \
    $IPS/aftab_datapath/aftab_sulu.vhd \
    $IPS/aftab_datapath/aftab_register_file.vhd \
    $IPS/aftab_datapath/aftab_csr/aftab_csr_address_ctrl.vhd \
    $IPS/aftab_datapath/aftab_csr/aftab_csr_address_logic.vhd \
    $IPS/aftab_datapath/aftab_csr/aftab_csr_addressing_decoder.vhd \
    $IPS/aftab_datapath/aftab_csr/aftab_csr_counter.vhd \
    $IPS/aftab_datapath/aftab_csr/aftab_csr_isl.vhd \
    $IPS/aftab_datapath/aftab_csr/aftab_csr_registers.vhd \
    $IPS/aftab_datapath/aftab_csr/aftab_iccd.vhd \
    $IPS/aftab_datapath/aftab_csr/aftab_isagu.vhd \
    $IPS/aftab_datapath/aftab_csr/aftab_register_bank.vhd \
    $IPS/aftab_datapath/aftab_aau/aftab_shift_register.vhd \
    $IPS/aftab_datapath/aftab_aau/aftab_booth_multiplier/aftab_booth_multiplier_controller.vhd \
    $IPS/aftab_datapath/aftab_aau/aftab_booth_multiplier/aftab_booth_multiplier_datapath.vhd \
    $IPS/aftab_datapath/aftab_aau/aftab_booth_multiplier/aftab_booth_multiplier.vhd \
    $IPS/aftab_datapath/aftab_aau/aftab_su_divider/aftab_divider_controller.vhd \
    $IPS/aftab_datapath/aftab_aau/aftab_su_divider/aftab_divider_datapath.vhd \
    $IPS/aftab_datapath/aftab_aau/aftab_su_divider/aftab_divider.vhd \
    $IPS/aftab_datapath/aftab_aau/aftab_su_divider/aftab_tcl.vhd \
    $IPS/aftab_datapath/aftab_aau/aftab_su_divider/aftab_su_divider.vhd \
    $IPS/aftab_datapath/aftab_aau/aftab_su_divider/aftab_divider.vhd \
    $IPS/aftab_datapath/aftab_aau/aftab_aau.vhd \
    $IPS/aftab_datapath/aftab_daru/aftab_daru_controller.vhd \
    $IPS/aftab_datapath/aftab_daru/aftab_daru_error_detector.vhd \
    $IPS/aftab_datapath/aftab_daru/aftab_daru_datapath.vhd \
    $IPS/aftab_datapath/aftab_daru/aftab_daru.vhd \
    $IPS/aftab_datapath/aftab_dawu/aftab_dawu_controller.vhd \
    $IPS/aftab_datapath/aftab_dawu/aftab_dawu_error_detector.vhd \
    $IPS/aftab_datapath/aftab_dawu/aftab_dawu_datapath.vhd \
    $IPS/aftab_datapath/aftab_dawu/aftab_dawu.vhd \
    $IPS/aftab_datapath/aftab_datapath.vhd \
    $IPS/aftab_controller.vhd \
    $IPS/aftab_core.vhd"
    
#fpga ips
set FPGA_IPS_COMPONENTS " \
    $FPGA_IPS/altera_mem_16384x8_dp.vhd \
    $FPGA_IPS/altera_mem_mc2101_controller.vhd \
    $FPGA_IPS/altera_mem_mc2101_bus_wrap.vhd"
 
#rtl components  
set SRC_RTL_COMPONENTS " \
    $RTL/gpio/gpio_pads_if.vhd \
    $RTL/gpio/gpio_core.vhd \
    $RTL/gpio/gpio.vhd \
    $RTL/gpio/gpio_controller.vhd \
    $RTL/gpio/gpio_bus_wrap.vhd \
    $RTL/uart/uart_tx_core.vhd \
    $RTL/uart/uart_rx_core.vhd \
    $RTL/uart/fifo.vhd \
    $RTL/uart/uart_interrupt.vhd \
    $RTL/uart/uart.vhd \
    $RTL/uart/uart_controller.vhd \
    $RTL/uart/uart_bus_wrap.vhd \
    $RTL/core_bus_wrap.vhd \
    $RTL/mc2101.vhd"
    
#check if some source files are missing
foreach f $SRC_IPS_COMPONENTS {
    if {[file exists $f]==0} {
        puts "Source file $f doesn't exist!"
        exit 1
    }
}

foreach f $FPGA_IPS_COMPONENTS {
    if {[file exists $f]==0} {
        puts "Source file $f doesn't exist!"
        exit 1
    }
}

foreach f $SRC_RTL_COMPONENTS {
    if {[file exists $f]==0} {
        puts "Source file $f doesn't exist!"
        exit 1
    }
}

if {[file exists $f]==0} {
    puts "No $f sdc file found, you should specify timing constraints before proceeding.."
}
    

#open project or create it if doesn't exist
package require ::quartus::project

if {[is_project_open]} {
    #there is an open project, do not export assignment
    if {[string compare $quartus(project) $project_name]} {
        puts "Project $project_name is not open"
        set make_assignment 0
    }
} else {
    #open or create new project
    if {[project_exists $project_name]} {
        project_open $project_name
    } else {
        puts "Project $project_name doesn't exist, creting it.."
        project_new $project_name -overwrite
    }
    #project needs to be closed after everything is completed
    set close_project 1
}

#set project assignment and commit them!
if {$make_assignment} {
    set_global_assignment -name FAMILY "Cyclone V" 
    set_global_assignment -name DEVICE 5CSEMA5F31C6
    set_global_assignment -name PROJECT_OUTPUT_DIRECTORY output_files
    set_global_assignment -name RESERVE_ALL_UNUSED_PINS_WEAK_PULLUP "AS INPUT TRI-STATED"
    set_global_assignment -name TOP_LEVEL_ENTITY mc2101
    
    #clean VHDL_FILE global assignment
    remove_all_global_assignments -name VHDL_FILE
    
    #add vhdl design files
    foreach f $SRC_IPS_COMPONENTS {
        set_global_assignment -name VHDL_FILE $f -hdl_version VHDL_2008
    }  
    foreach f $FPGA_IPS_COMPONENTS {
        set_global_assignment -name VHDL_FILE $f -hdl_version VHDL_2008
    }
    foreach f $SRC_RTL_COMPONENTS {
        set_global_assignment -name VHDL_FILE $f -hdl_version VHDL_2008
    }
     
    #sys_clk-->50 MHz clock
    set_location_assignment PIN_AF14 -to sys_clk
    #sys_rst_n-->KEY0 (button)
    set_location_assignment PIN_AA14 -to sys_rst_n
    #uart_tx-->2x20 GPIO Exapansion Headers GPIO_0[1]
    set_location_assignment PIN_Y17 -to uart_tx
    #uart_rx-->2x20 GPIO Exapansion Headers GPIO_0[3]
    set_location_assignment PIN_Y18 -to uart_rx
    #gpio[0 TO 9]-->slide switches SW[0 TO 9]
    set_location_assignment PIN_AB12 -to gpio_pads[0]
    set_location_assignment PIN_AC12 -to gpio_pads[1]
    set_location_assignment PIN_AF9  -to gpio_pads[2]
    set_location_assignment PIN_AF10 -to gpio_pads[3]
    set_location_assignment PIN_AD11 -to gpio_pads[4]
    set_location_assignment PIN_AD12 -to gpio_pads[5]
    set_location_assignment PIN_AE11 -to gpio_pads[6]
    set_location_assignment PIN_AC9  -to gpio_pads[7]
    set_location_assignment PIN_AD10 -to gpio_pads[8]
    set_location_assignment PIN_AE12 -to gpio_pads[9]
    #gpio[10 TO 19]-->leds LED[0 TO 9]
    set_location_assignment PIN_V16 -to gpio_pads[10]
    set_location_assignment PIN_W16 -to gpio_pads[11]
    set_location_assignment PIN_V17 -to gpio_pads[12]
    set_location_assignment PIN_V18 -to gpio_pads[13]
    set_location_assignment PIN_W17 -to gpio_pads[14]
    set_location_assignment PIN_W19 -to gpio_pads[15]
    set_location_assignment PIN_Y19 -to gpio_pads[16]
    set_location_assignment PIN_W20 -to gpio_pads[17]
    set_location_assignment PIN_W21 -to gpio_pads[18]
    set_location_assignment PIN_Y21 -to gpio_pads[19]
    #gpio[20 to 22]-->KEY1,2,3 Button
    set_location_assignment PIN_AA15 -to gpio_pads[20]
    set_location_assignment PIN_W15  -to gpio_pads[21]
    set_location_assignment PIN_Y16  -to gpio_pads[22]
    
    #commit assignment
    export_assignments
}

#######################################################
####check vhdl syntax before proceding to synthesis####
#######################################################
puts "(COMPILATION)"
set cmd "quartus_map --read_settings_files=on \
	                 --write_settings_files=off \
	                 $project_name \
	                 --optimize=balanced \
	        --state_machine_encoding=minimal_bits"
	                  
qexec $cmd

#######################################################
#############place and route process###################
#######################################################
puts "(FITTER)"
set cmd "quartus_fit --read_settings_files=on \
                     --write_settings_files=off \
	                 $project_name"
	             
qexec $cmd

#######################################################
#########static timing analysis process################
#######################################################	 
puts "(STA)"
set cmd "quartus_sta --sdc=$SDC_FILE \
	                 --do_report_timing \
	                 $project_name \
	                 -model=slow"

qexec $cmd	                 
puts "STA report can be found in output_files/ directory"

#######################################################
################Assembler process######################
#######################################################	                             
puts "(ASM)"
set cmd "quartus_asm --read_settings_files=on \
	                 --write_settings_files=off \
	                 $project_name"

qexec $cmd	                 
puts "Program file .sof can be found in ouput_files/ directory"


if {$close_project} {
    puts "Closing $project_name.."
    project_close
}
