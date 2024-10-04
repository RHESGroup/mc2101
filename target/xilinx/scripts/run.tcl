# Copyright 2018 ETH Zurich and University of Bologna.
# Solderpad Hardware License, Version 0.51, see LICENSE for details.
# SPDX-License-Identifier: SHL-0.51
#
# Author: Florian Zaruba <zarubaf@iis.ee.ethz.ch>

set current_directory [file normalize [pwd]]
puts $current_directory

# Ips selection
switch $::env(BOARD) {
      "pynq-z1" {
            set ips {
                  "../../IP/BlockMemGenerator/blk_mem_gen_0.srcs/sources_1/ip/blk_mem_gen_0/blk_mem_gen_0.xci" \
                  "../../IP/ILA/ila_0.srcs/sources_1/ip/ila_0/ila_0.xci"
            }
      }
      default {
            set ips {}
      }
}

#This command reads all output products associated with the IP core, including the design checkpoint file (DCP), into the in-memory design
#This allows you to reuse the previously synthesized IP without needing to regenerate it, which can save time and resources
# Vivado will check the cache directory for the IP core. 
#If the IP core is found in the cache and hasn’t changed, it will use the cached version instead of re-synthesizing it
#Vivado automatically checks if there have been any changes to the IP core. If there are no changes, it uses the cached version. 
#If there are changes, it will re-synthesize the IP core and update the cache
read_ip $ips 

set board $::env(BOARD)

source scripts/add_sources.tcl

add_files -fileset constrs_1 -norecurse $current_directory/constraints/$board.xdc

set_property top mc2101_wrapper [current_fileset]

update_compile_order -fileset sources_1

#Set the file to be added to the memory
set file_to_memory $::env(file)
set path_file "${current_directory}/../../util/${file_to_memory}.coe"
puts $path_file
set_property -dict [list \
  CONFIG.Coe_File $path_file \
  CONFIG.Load_Init_File {true} \
] [get_ips blk_mem_gen_0]



set_property strategy Flow_PerfOptimized_high [get_runs synth_1]
set_property strategy Performance_ExtraTimingOpt [get_runs impl_1]

set_property XPM_LIBRARIES XPM_MEMORY [current_project]

set_param general.maxThreads 16

#Generate the Outout products of the IPs which have changed
foreach ip [get_ips] {
    generate_target {all} $ip
}
synth_design -rtl -name rtl_1

set_property STEPS.SYNTH_DESIGN.ARGS.RETIMING true [get_runs synth_1]
set_property STEPS.SYNTH_DESIGN.ARGS.DIRECTIVE PowerOptimized_high [get_runs synth_1]

launch_runs synth_1
wait_on_run synth_1

update_compile_order -fileset sources_1
open_run synth_1 -name synth_1

update_compile_order -fileset sources_1
open_run synth_1 -name synth_1

# Get all nets of the design
set all_nets [get_nets -hierarchical]
 

# Initialize an empty list to store nets marked for debugging
set nets_to_set {}

# Loop through each net and check if it's marked for debugging
foreach net $all_nets {
    if {[get_property MARK_DEBUG $net] == 1} {
        lappend nets_to_set $net
    }
}

puts $nets_to_set


#Know the number of the nets to add
set length [llength $nets_to_set]

# Print the list of nets marked for debug
if {$length > 0} {
      #The name of the core is "ila". We are using the ip "ila_0"
      create_debug_core ila_0 ila
      puts "The signals marked for debug are:"
      for {set index 0} {$index <= $length - 1} {incr index} {

            set new_net [ get_nets [ lindex $nets_to_set $index ] ]
            set probe "probe$index"
            
            puts $new_net

            if {$index != 0} {
                  create_debug_port [get_debug_cores ila_0] probe  
            }

            connect_debug_port [get_debug_cores ila_0]/$probe [ get_nets $new_net]
      }     
      #Connect the debug core to the clock
      connect_debug_port [get_debug_cores ila_0]/clk [ get_nets MC2101_1/sys_clk] 

} else {

    puts "No nets marked for debug."
}

exec mkdir -p reports/
exec rm -rf reports/*Sroject.utilization.rpt
report_cdc                                                              -file reports/$project.cdc.rpt
report_clock_interaction                                                -file reports/$project.clock_interaction.rpt



set_property STEPS.PHYS_OPT_DESIGN.ARGS.DIRECTIVE AggressiveExplore [get_runs impl_1]
set_property STEPS.ROUTE_DESIGN.ARGS.DIRECTIVE Explore [get_runs impl_1]
launch_runs impl_1
wait_on_run impl_1
launch_runs impl_1 -to_step write_bitstream
wait_on_run impl_1

#Check timing constraints
open_run impl_1
set timingrep [report_timing_summary -no_header -no_detailed_paths -return_string]
if {[info exists ::env(CHECK_TIMING)] && $::env(CHECK_TIMING)==1} {
      if {! [string match -nocase {*timing constraints are met*} $timingrep]} {
            send_msg_id {USER 1-1} ERROR {Timing constraints were not met.}
            return -code error
      }
}


# reports
exec mkdir -p reports/
exec rm -rf reports/*
check_timing                                                              -file reports/${project}.check_timing.rpt
report_timing -max_paths 100 -nworst 100 -delay_type max -sort_by slack   -file reports/${project}.timing_WORST_100.rpt
report_timing -nworst 1 -delay_type max -sort_by group                    -file reports/${project}.timing.rpt
report_utilization -hierarchical                                          -file reports/${project}.utilization.rpt
