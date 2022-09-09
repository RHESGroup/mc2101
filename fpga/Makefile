# **************************************************************************************
#	Filename:	Makefile
#	Project:	CNL_RISC-V
#  	Version:	1.0
#	History:
#	Date:		9 Sep 2022
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

#bash script for programmer
PGM_SCRIPT=$(CURR_DIR)/utils/programmer.sh

#memory initialization file
SRC_MIF=$(CURR_DIR)/utils/program.mif

#quartus synthesis script
SYN_SCRIPT=$(CURR_DIR)/utils/synthesis.tcl

#bash script for converting .s19 -> spi_stim -> .mif
GEN_MIF_SCRIPT=$(CURR_DIR)/utils/spi_to_mif.sh

update_ram: generate_mif $(SRC_MIF)
	$(QUARTUS_CDB_EXE) $(DESIGN_NAME) --update_mif
	$(QUARTUS_ASM_EXE)  \
		--read_settings_files=on \
		--write_settings_files=off \
		$(DESIGN_NAME)

generate_mif: $(GEN_MIF_SCRIPT)
	$(GEN_MIF_SCRIPT) $(TARGET_APP)
	

compile_design: $(SYN_SCRIPT)
	$(QUARTUS_SHELL) -t $(SYN_SCRIPT)
    
program_fpga: $(SOF_FILE) $(PGM_SCRIPT)
	$(PGM_SCRIPT)

clean_all: 
	rm -rf $(CURR_DIR)/db
	rm -rf $(CURR_DIR)/incremental_db
    
