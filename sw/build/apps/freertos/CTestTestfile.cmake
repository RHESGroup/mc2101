# CMake generated Testfile for 
# Source directory: /media/sf_Shared/pulpino/sw/apps/freertos
# Build directory: /media/sf_Shared/pulpino/sw/build/apps/freertos
# 
# This file includes the relevant testing commands required for 
# testing this directory and lists subdirectories to be tested as well.
add_test(freertos.test "tcsh" "-c" "env VSIM_DIR=/media/sf_Shared/pulpino/vsim USE_ZERO_RISCY=1 RISCY_RV32F=0 ZERO_RV32M=1 ZERO_RV32E=0 PL_NETLIST= TB_TEST=\"\" /opt/intelFPGA/20.1/modelsim_ase/linuxaloem/vsim  -c -64 -do 'source tcl_files/run.tcl; run_and_exit;'")
set_tests_properties(freertos.test PROPERTIES  WORKING_DIRECTORY "/media/sf_Shared/pulpino/sw/build/apps/freertos/")
