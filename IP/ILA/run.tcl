set partNumber $::env(XILINX_PART)
set boardName  $::env(XILINX_BOARD)

set ipName ila_0

set current_directory [file normalize [pwd]]
puts $current_directory

create_project $ipName $current_directory/../../IP/ILA -force -part $partNumber
set_property board_part $boardName [current_project]
set_property target_language VHDL [current_project]

create_ip -name ila -vendor xilinx.com -library ip -version 6.2 -module_name $ipName

close_project



