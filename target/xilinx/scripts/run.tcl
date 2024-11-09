#Script to set up the project

set current_directory [file normalize [pwd]]
puts $current_directory

# Ips selection
switch $::env(BOARD) {
      "pynq-z1" {
            set ips {
                  "./IP/BlockMemGenerator/blk_mem_gen_0.srcs/sources_1/ip/blk_mem_gen_0/blk_mem_gen_0.xci" \
                  "./IP/ILA/ila_0.srcs/sources_1/ip/ila_0/ila_0.xci" \
                  "./IP/ClkWizard/clk_wiz_0.srcs/sources_1/ip/clk_wiz_0/clk_wiz_0.xci" 
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

add_files -fileset constrs_1 -norecurse $current_directory/constraints/physical_constraints_${board}.xdc $current_directory/constraints/timing_constraints_${board}.xdc

set_property top mc2101_wrapper [current_fileset]




