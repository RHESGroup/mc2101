set partNumber $::env(XILINX_PART)
set boardName  $::env(XILINX_BOARD)

set file_to_memory $::env(file)

set ipName blk_mem_gen_0

set current_directory [file normalize [pwd]]
puts $current_directory

create_project $ipName $current_directory/ips/BlockMemGenerator -force -part $partNumber
set_property board_part $boardName [current_project]

create_ip -name blk_mem_gen -vendor xilinx.com -library ip -version 8.4 -module_name $ipName

set path_file "../../../../../../../../util/${file_to_memory}.coe"

if {$::env(BOARD) eq "pynq-z1"} {
    set_property -dict [list \
                        CONFIG.Memory_Type {Simple_Dual_Port_RAM} \
                        CONFIG.Coe_File $path_file \
                        CONFIG.Load_Init_File {true} \
                        CONFIG.Use_RSTA_Pin {true} \
                        CONFIG.Write_Depth_A {16384} \
                        CONFIG.Write_Width_A {8} \
                        CONFIG.Register_PortB_Output_of_Memory_Primitives {false} \

    ] [get_ips $ipName]

} else {
    exit 1
}


puts "END IP configuration"

generate_target {instantiation_template} [get_files $current_directory/ips/BlockMemGenerator/$ipName.srcs/sources_1/ip/$ipName/$ipName.xci]
generate_target all [get_files  $current_directory/ips/BlockMemGenerator/$ipName.srcs/sources_1/ip/$ipName/$ipName.xci]
create_ip_run [get_files -of_objects [get_fileset sources_1] $current_directory/ips/BlockMemGenerator/$ipName.srcs/sources_1/ip/$ipName/$ipName.xci]
launch_run -jobs 8 ${ipName}_synth_1
wait_on_run ${ipName}_synth_1
close_project



