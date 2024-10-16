#Script to run synthesis

#Open the project(if it is not already open)
set project mc2101
#set project $::env(PROJECT)
set current_projects [get_projects]
if { ![string equal -nocase $current_projects $project]} { #If the project is not currently open, open it
	open_project ./Work_directory/${project}
}

set current_directory [file normalize [pwd]]


#File to be uploaded into the memory
set file_to_memory "memory_initialization_board_test_general"
#set file_to_memory $::env(file)
set path_file "${current_directory}/../../util/${file_to_memory}.coe"

#Read the BRAM property to see what file is alredy included in the IP(if any)
set current_fileBRAM [get_property CONFIG.Coe_File [get_ips blk_mem_gen_0] ]
puts $current_fileBRAM


set_property strategy Flow_PerfOptimized_high [get_runs synth_1]
set_property strategy Performance_ExtraTimingOpt [get_runs impl_1]

set_property XPM_LIBRARIES XPM_MEMORY [current_project]

set_param general.maxThreads 16 

#Disables automatic incremental checkpointing for the specified run
set_property AUTO_INCREMENTAL_CHECKPOINT 0 [get_runs synth_1]


#Set the system with incremental synthesis: It detects when the design has
#changed and only re-runs synthesis on sections of the design that have changed. The key
#advantage of this flow is that the runtime is significantly reduced for designs with small changes.
#Read the checkpoint file to see if it has changed
set dcp_file "${project}.dcp"
set path_to_dcp "${current_directory}/Work_directory/${dcp_file}"
set a [file exists $path_to_dcp]
puts $a
if {[file exists $path_to_dcp]} { #This is run if we have already run synthesis and generated a checkpointer

    puts "There is one checkpointer(DCP file)"

    #Use regexpression to get the name of the file saved in the BRAM
    regexp {([^/]+)\.coe$} $current_fileBRAM match filenameBRAM

    if {$file_to_memory ne $filenameBRAM} { #This is run if we are running synthesis with a different piece of code. We use incremental synthesis to save time
        
        puts "It will be used for incremental synthesis"

        # Sets the specified checkpoint file as the incremental checkpoint for the synthesis run. 
        #This means that the synthesis process  will use this checkpoint to determine which parts of the 
        #design need to be re-synthesized.

        #Check if the DCP has already been added to the project
        if { [llength [get_files $path_to_dcp]] > 0 } {
            puts "DCP already exists in the project."
            update_files -force -from_files $path_to_dcp

        } else {
            puts "DCP does not exist in the project."
            puts "It will be added"
            add_files -fileset utils_1 -norecurse $path_to_dcp
            set_property incremental_checkpoint $path_to_dcp [get_runs synth_1]
        }


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

        open_run synth_1
        #Write the checkpoint. This saves the design at the synthesis point, so that we can quickly import it back into the tool for incremental synthesis
        write_checkpoint -force $path_to_dcp

    } else { #The code is the same than last time, so there is no need to run synthesis again
    
        puts "The design does not need to synthesize again because it hasn't had changes" 
    }




} else { #This is run if we haven't run synthesis yet

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
    synth_design -rtl -name rtl_1

    #set_property STEPS.SYNTH_DESIGN.ARGS.RETIMING true [get_runs synth_1]
    #set_property STEPS.SYNTH_DESIGN.ARGS.DIRECTIVE PowerOptimized_high [get_runs synth_1]

    launch_runs synth_1 -jobs 16
    wait_on_run synth_1

    update_compile_order -fileset sources_1

    open_run synth_1
    #Write the checkpoint. This saves the design at the synthesis point, so that we can quickly import it back into the tool for incremental synthesis
    write_checkpoint -force $path_to_dcp
}



