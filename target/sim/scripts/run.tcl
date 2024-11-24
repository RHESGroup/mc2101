#Script to set up the project

set current_directory [file normalize [pwd]]
set board $::env(BOARD)

source scripts/add_sources.tcl

set_property top mc2101_wrapper [current_fileset]

