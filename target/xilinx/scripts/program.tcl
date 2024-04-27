open_hw_manager

connect_hw_server -url $::env(HOST):$::env(PORT)

if {$::env(BOARD) eq "PYNQ-Z1"} {
  open_hw_target $::env(HOST):$::env(PORT)/$::env(FPGA_PATH)

  current_hw_device [get_hw_devices xc7z020_1]
  set_property PROGRAM.FILE $::env(BIT) [get_hw_devices xc7z020_1]
  program_hw_devices [get_hw_devices xc7z020_1]
  refresh_hw_device [lindex [get_hw_devices xc7z020_1] 0]
} else {
      exit 1
}
