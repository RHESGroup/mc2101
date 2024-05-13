# **************************************************************************************
#	Filename:	Makefile
#	Project:	CNL_RISC-V
#  	Version:	2.0
#	History:
#	Date:		13 May 2024
#
# Copyright (C) 2022 CINI Cybersecurity National Laboratory
#
# This source file may be used and distributed without
# restriction provided that this copyright statement is not
# removed from the file and that any derivative work contains
# the original copyright notice and the associated disclaimer.
#
# This source file is free software; you can redistribute it
# and/or modify it under the terms of the GNU Lesser General
# Public License as published by the Free Software Foundation;
# either version 3.0 of the License, or (at your option) any
# later version.
#
# This source is distributed in the hope that it will be
# useful, but WITHOUT ANY WARRANTY; without even the implied
# warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR
# PURPOSE. See the GNU Lesser General Public License for more
# details.
#
# You should have received a copy of the GNU Lesser General
# Public License along with this source; if not, download it
# from https://www.gnu.org/licenses/lgpl-3.0.txt
#
# **************************************************************************************
#
#	File content description:
#	#make commands useful for fpga usage
#
# **************************************************************************************


#target application to test
TARGET_APP=board_test_general

#quartus project name
DESIGN_NAME=mc2101
CURR_DIR=$(shell pwd)

#.sof file used to program the fpga
SOF_FILE=$(CURR_DIR)/output_files/$(DESIGN_NAME).sof

#quartus command to update the db/ with new mif file
QUARTUS_CDB_EXE=$(shell which quartus_cdb)

#quartus assembler 
QUARTUS_ASM_EXE=$(shell which quartus_asm)

#quartus shell where to execute tcl synthesis
QUARTUS_SHELL=$(shell which quartus_sh)

#memory initialization file
SRC_MIF=$(CURR_DIR)/../../util/$(TARGET_APP).mif


BENDER ?= bender

#bash script for programmer
PGM_SCRIPT=$(CURR_DIR)/script/programmer.sh

#quartus synthesis script
SYN_SCRIPT=$(CURR_DIR)/scripts/synthesis.tcl



update_ram: generate_mif $(SRC_MIF)
	$(QUARTUS_CDB_EXE) $(DESIGN_NAME) --update_mif
	$(QUARTUS_ASM_EXE)  \
		--read_settings_files=on \
		--write_settings_files=off \
		$(DESIGN_NAME)



compile_design: $(SYN_SCRIPT)
	$(BENDER) script vsim -t intel > ./scripts/add_sources.txt
	$(QUARTUS_SHELL) -t source $(SYN_SCRIPT)

    
program_fpga: $(SOF_FILE) $(PGM_SCRIPT)
	$(PGM_SCRIPT)

update_ips:
	$(BENDER) update

clean_all: 
	rm -rf $(CURR_DIR)/db
	rm -rf $(CURR_DIR)/incremental_db
    

help: 
	@printf "\033[1mSystem creation\033[0m\n"
	@printf "\033[31m\tcompile_design\033[39m Create the environment and run synthesis. Remember: make -f FPGA.k compile_design TARGET_APP=namefile\n"
	@printf "\033[31m\tprogram_fpga\033[39m Program the FPGA with the bistream previously generated\n"
	@printf "\033[31m\tupdate_ram\033[39m Update the .mif file read by the memory\n"
	@printf "\033[31m\tupdate_ips\033[39m Update the BENDER dependencies\n"
	@printf "\033[31m\tclean_all\033[39m Eliminate files associated with the project\n"


