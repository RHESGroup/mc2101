set current_directory [file normalize [pwd]]
puts $current_directory

set project $::env(PROJECT)


open_hw_manager

connect_hw_server -url $::env(HOST):$::env(PORT)

if {$::env(BOARD) eq "pynq-z1"} {
  current_hw_target [lindex [get_hw_targets] 0]
  open_hw_target
  set_property PROGRAM.FILE $::env(BIT) [lindex [get_hw_devices xc7z020_1] 0]
  set_property PROBES.FILE ${current_directory}/out/${project}_wrapper.ltx [get_hw_devices xc7z020_1]
  set_property FULL_PROBES.FILE ${current_directory}/out/${project}_wrapper.ltx [get_hw_devices xc7z020_1]
  current_hw_device [lindex [get_hw_devices xc7z020_1] 0]
  program_hw_devices [get_hw_devices xc7z020_1]
  refresh_hw_device [lindex [get_hw_devices xc7z020_1] 0]
  puts "The FPGA was properly programmed"
  disconnect_hw_server
  

} else {
      exit 1
      puts "The FPGA was not properly programmed"
}
