set project $::env(PROJECT)

create_project $project . -force -part $::env(XILINX_PART)
set_property board_part $::env(XILINX_BOARD) [current_project]

# set number of threads to 8 (maximum, unfortunately)
set_param general.maxThreads 8


