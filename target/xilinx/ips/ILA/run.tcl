set partNumber $::env(XILINX_PART)
set boardName  $::env(XILINX_BOARD)

set ipName ila_0

set current_directory [file normalize [pwd]]
puts $current_directory

create_project $ipName $current_directory/ips/ILA -force -part $partNumber
set_property board_part $boardName [current_project]

create_ip -name ila -vendor xilinx.com -library ip -version 6.2 -module_name $ipName


generate_target {instantiation_template} [get_files $current_directory/ips/ILA/$ipName.srcs/sources_1/ip/$ipName/$ipName.xci]
generate_target all [get_files  $current_directory/ips/ILA/$ipName.srcs/sources_1/ip/$ipName/$ipName.xci]
create_ip_run [get_files -of_objects [get_fileset sources_1] $current_directory/ips/ILA/$ipName.srcs/sources_1/ip/$ipName/$ipName.xci]
launch_run -jobs 16 ${ipName}_synth_1
wait_on_run ${ipName}_synth_1
close_project



