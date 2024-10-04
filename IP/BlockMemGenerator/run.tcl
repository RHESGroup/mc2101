set partNumber $::env(XILINX_PART)
set boardName  $::env(XILINX_BOARD)


set ipName blk_mem_gen_0

set current_directory [file normalize [pwd]]
puts $current_directory

create_project $ipName $current_directory/ips/BlockMemGenerator -force -part $partNumber
set_property board_part $boardName [current_project]
set_property target_language VHDL [current_project]

create_ip -name blk_mem_gen -vendor xilinx.com -library ip -version 8.4 -module_name $ipName

if {$::env(BOARD) eq "pynq-z1"} {
    set_property -dict [list \
                        CONFIG.Memory_Type {Simple_Dual_Port_RAM} \
                        CONFIG.Use_RSTA_Pin {true} \
                        CONFIG.Write_Depth_A {16384} \
                        CONFIG.Write_Width_A {8} \
                        CONFIG.Register_PortB_Output_of_Memory_Primitives {false} \
    ] [get_ips $ipName]

} else {
    exit 1
}

puts "END IP configuration"

close_project



