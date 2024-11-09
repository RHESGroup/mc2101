#Script to run implementation

#Open the project(if it is not already open)
set project $::env(PROJECT)
set current_projects [get_projects]
if { ![string equal -nocase $current_projects $project]} { #If the project is not currently open, open it
	open_project ./Work_directory/${project}.xpr
}

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
report_utilization                                                      -file reports/$project.utilization.rpt


#set_property STEPS.PHYS_OPT_DESIGN.ARGS.DIRECTIVE AggressiveExplore [get_runs impl_1]
#set_property STEPS.ROUTE_DESIGN.ARGS.DIRECTIVE Explore [get_runs impl_1]
launch_runs impl_1 -to_step write_bitstream
wait_on_run impl_1