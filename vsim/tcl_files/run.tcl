# **************************************************************************************
#  Filename: run.tcl  #
#  Project:  CNL_RISC-V
#  Version:  1.0
#  History:
#  Date:     09 May, 2022  #
#
# Copyright (C) 2022 CINI Cybersecurity National Laboratory and University of Teheran
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
#  File content description:
#  Run ModelSim simulation of the target through GUI  #
#
# **************************************************************************************

vsim -quiet work.tb_hsystem +nowarnTRAN +nowarnTSCALE +nowarnTFMPC -t 1ns -voptargs="+acc -suppress 2103" -dpicpppath /usr/bin/gcc 

#modified by luca, simulation for hsystem

#global signals
add wave -noupdate -group GLOBALS -radix hexadecimal /tb_hsystem/clk
add wave -noupdate -group GLOBALS -radix hexadecimal /tb_hsystem/rst

#hbus signals
add wave -noupdate -group HBUS -radix hexadecimal /tb_hsystem/system/hready
add wave -noupdate -group HBUS -radix hexadecimal /tb_hsystem/system/hselram
add wave -noupdate -group HBUS -radix hexadecimal /tb_hsystem/system/hselflash
add wave -noupdate -group HBUS -radix hexadecimal /tb_hsystem/system/hselgpio
add wave -noupdate -group HBUS -radix hexadecimal /tb_hsystem/system/hseluart
add wave -noupdate -group HBUS -radix hexadecimal /tb_hsystem/system/hwrite
add wave -noupdate -group HBUS -radix hexadecimal /tb_hsystem/system/hwrdata
add wave -noupdate -group HBUS -radix hexadecimal /tb_hsystem/system/haddr
add wave -noupdate -group HBUS -radix hexadecimal /tb_hsystem/system/hrdata
add wave -noupdate -group HBUS -radix hexadecimal /tb_hsystem/system/hresp

#hslave(1) RAM signals
add wave -noupdate -group SSRAM -radix hexadecimal /tb_hsystem/system/slave_ram/controller/current_state
add wave -noupdate -group SSRAM -radix hexadecimal /tb_hsystem/system/slave_ram/memory/address
add wave -noupdate -group SSRAM -radix hexadecimal /tb_hsystem/system/slave_ram/memory/dataIn
add wave -noupdate -group SSRAM -radix hexadecimal /tb_hsystem/system/slave_ram/memory/dataOut
add wave -noupdate -group SSRAM -radix hexadecimal /tb_hsystem/system/slave_ram/memory/mem
add wave -noupdate -group SSRAM -radix hexadecimal /tb_hsystem/system/slave_ram/memory/readMem
add wave -noupdate -group SSRAM -radix hexadecimal /tb_hsystem/system/slave_ram/memory/writeMem

#hslave(2) FLASH signals
add wave -noupdate -group FLASH -radix hexadecimal /tb_hsystem/system/slave_flash/controller/current_state
add wave -noupdate -group FLASH -radix hexadecimal /tb_hsystem/system/slave_flash/memory/address
add wave -noupdate -group FLASH -radix hexadecimal /tb_hsystem/system/slave_flash/memory/enable
add wave -noupdate -group FLASH -radix hexadecimal /tb_hsystem/system/slave_flash/memory/dataOut

#master interface  signals
add wave -noupdate -group MASTERIF -radix hexadecimal /tb_hsystem/system/master/read
add wave -noupdate -group MASTERIF -radix hexadecimal /tb_hsystem/system/master/write
add wave -noupdate -group MASTERIF -radix hexadecimal /tb_hsystem/system/master/curr_bus_state
add wave -noupdate -group MASTERIF -radix hexadecimal /tb_hsystem/system/master/curr_arb_state
add wave -noupdate -group MASTERIF -radix hexadecimal /tb_hsystem/system/master/grant

#bootloader signals
add wave -noupdate -group BOOTL -radix hexadecimal /tb_hsystem/system/master/bootloader/current_state
add wave -noupdate -group BOOTL -radix hexadecimal /tb_hsystem/system/master/blDataOut
add wave -noupdate -group BOOTL -radix hexadecimal /tb_hsystem/system/master/blReadReq
add wave -noupdate -group BOOTL -radix hexadecimal /tb_hsystem/system/master/blWriteReq
add wave -noupdate -group BOOTL -radix hexadecimal /tb_hsystem/system/master/blAddr
add wave -noupdate -group BOOTL -radix hexadecimal /tb_hsystem/system/master/boot_end
add wave -noupdate -group BOOTL -radix hexadecimal /tb_hsystem/system/master/hrdata

#core signals
add wave -noupdate -group CORE -radix hexadecimal /tb_hsystem/system/master/coreOnInterrupt
add wave -noupdate -group CORE -radix hexadecimal /tb_hsystem/system/master/coreMemReady
add wave -noupdate -group CORE -radix hexadecimal /tb_hsystem/system/master/coreDout
add wave -noupdate -group CORE -radix hexadecimal /tb_hsystem/system/master/coreReadReq
add wave -noupdate -group CORE -radix hexadecimal /tb_hsystem/system/master/coreWriteReq
add wave -noupdate -group CORE -radix hexadecimal /tb_hsystem/system/master/coreAddr
add wave -noupdate -group CORE -radix hexadecimal /tb_hsystem/system/master/core/datapathAFTAB/registerFile/rData

#run $var ns



