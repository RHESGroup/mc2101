#Script to run synthesis

#Open the project(if it is not already open)
set project $::env(PROJECT)
set current_projects [get_projects]
if { ![string equal -nocase $current_projects $project]} { #If the project is not currently open, open it
	open_project ./Work_directory/${project}
}

set current_directory [file normalize [pwd]]


# #File to be uploaded into the memory
# set file_to_memory "memory_initialization_board_test_general"
set file_to_memory $::env(file)
set path_file "${current_directory}/../../util/${file_to_memory}.coe"

#Read the BRAM property to see what file is alredy included in the IP(if any)
set current_fileBRAM [get_property CONFIG.Coe_File [get_ips blk_mem_gen_0] ]
puts $current_fileBRAM


# set_property strategy Flow_PerfOptimized_high [get_runs synth_1]
# set_property strategy Performance_ExtraTimingOpt [get_runs impl_1]

#Check if there is already a DCP available
set dcp_file "${project}_wrapper.dcp"
set path_to_dcp "${current_directory}/Work_directory/mc2101.srcs/utils_1/imports/synth_1/${dcp_file}"
if {[file exists $path_to_dcp]} { #This is run if we have already run synthesis and generated a checkpointer

    #Use regexpression to get the name of the file saved in the BRAM
    regexp {([^/]+)\.coe$} $current_fileBRAM match filenameBRAM

    puts $file_to_memory
    puts $current_fileBRAM
    puts $filenameBRAM

    if {$file_to_memory ne $filenameBRAM} { #This is run if we are running synthesis with a different piece of code. We use incremental synthesis to save time
        puts "The old file saved in the BRAM was:" 
        puts $filenameBRAM
        puts "New COE file to save in BRAM memory is:"
        puts $file_to_memory

        #Set the file to be added to the memory
        set_property -dict [list \
        CONFIG.Coe_File $path_file \
        CONFIG.Load_Init_File {true} \
        ] [get_ips blk_mem_gen_0]

        update_compile_order -fileset sources_1


        #Synthesis must be re-run
        reset_run blk_mem_gen_0_synth_1
        reset_run synth_1
        launch_runs synth_1 -jobs 16
        wait_on_run synth_1
    } else {
        puts "The file saved in the BRAM is the same as the new COE file to save in BRAM memory. No need to run synthesis again."
    }

} else { #This is run if we haven't run synthesis yet

    #Use an autoincremental checkpoint to reduce the runtime of the synthesis process
    set_property AUTO_INCREMENTAL_CHECKPOINT.DIRECTORY /home/mc2101-pynq/Desktop/mc2101/target/xilinx/Work_directory/mc2101.srcs/utils_1/imports/synth_1 [get_runs synth_1]

    #Set the file to be added to the memory
    set_property -dict [list \
    CONFIG.Coe_File $path_file \
    CONFIG.Load_Init_File {true} \
    ] [get_ips blk_mem_gen_0]

    update_compile_order -fileset sources_1
    #Generate the Output products of the IPs which have changed..Use out-of-context synthesis
    foreach ip [get_ips] {
        generate_target {all} $ip
    }
 
    #Synthesize the full design
    #create_run -flow {Vivado Synthesis 2023} synth_1
    launch_runs synth_1 -jobs 16
    wait_on_run synth_1

    update_compile_order -fileset sources_1
}



