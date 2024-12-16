open_hw_manager

connect_hw_server -url $::env(HOST):$::env(PORT)

set current_directory [file normalize [pwd]]
puts $current_directory

set project $::env(PROJECT)
set bitstream_path ${current_directory}/Work_directory/${project}.runs/impl_1


if {$::env(BOARD) eq "PYNQ-Z1"} {
  open_hw_target $::env(HOST):$::env(PORT)/$::env(FPGA_PATH)

  current_hw_device [get_hw_devices xc7z020_1]
  set_property PROGRAM.FILE ${bitstream_path}/${project}_wrapper.bit [get_hw_devices xc7z020_1]
  program_hw_devices [get_hw_devices xc7z020_1]
  refresh_hw_device [lindex [get_hw_devices xc7z020_1] 0]
  puts "The FPGA was properly programmed"
  disconnect_hw_server
} else {
    puts "The FPGA was not properly programmed"
    exit 1
}
