set current_directory [file normalize [pwd]]

# Ips selection
switch $::env(BOARD) {
      "pynq-z1" {
            set ips {
                  "ips/BlockMemGenerator/blk_mem_gen_0.srcs/sources_1/ip/blk_mem_gen_0/blk_mem_gen_0.xci"
            }
      }
      default {
            set ips {}
      }
}

read_ip $ips

set board $::env(BOARD)

source scripts/add_sources.tcl
source scripts/add_mems.tcl

set_property top mc2101_wrapper [current_fileset]

update_compile_order -fileset sources_1
