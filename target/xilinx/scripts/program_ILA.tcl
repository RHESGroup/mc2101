
open_hw_manager

connect_hw_server -url $::env(HOST):$::env(PORT)

set current_directory [file normalize [pwd]]
puts $current_directory

set project $::env(PROJECT)

set bitstream_path ${current_directory}/Work_directory/${project}.runs/impl_1



if {$::env(BOARD) eq "pynq-z1"} {
  current_hw_target [lindex [get_hw_targets] 0]
  open_hw_target
  set_property PROGRAM.FILE ${bitstream_path}/${project}_wrapper.bit  [ get_hw_devices xc7z020_1 ]
  set_property PROBES.FILE ${bitstream_path}/${project}_wrapper.ltx [ get_hw_devices xc7z020_1]
  set_property FULL_PROBES.FILE ${bitstream_path}/${project}_wrapper.ltx [ get_hw_devices xc7z020_1]
  current_hw_device [lindex [get_hw_devices xc7z020_1] 0]
  program_hw_devices [get_hw_devices xc7z020_1]
  refresh_hw_device [lindex [get_hw_devices xc7z020_1] 0]
  puts "The FPGA was properly programmed"
  disconnect_hw_server
  
} else {
      exit 1
      puts "The FPGA was not properly programmed"
}
