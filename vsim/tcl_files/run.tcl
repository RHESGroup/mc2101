# **************************************************************************************
#  Filename: run.tcl  #
#  Project:  CNL_RISC-V
#  Version:  1.0
#  History:
#  Date:     1 Sep, 2022  #
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

vsim -quiet work.tb_mc2101 +nowarnTRAN +nowarnTSCALE +nowarnTFMPC -t 1ns -voptargs="+acc -suppress 2103" -dpicpppath /usr/bin/gcc 

#modified by luca, simulation for hmicrocontroller

#global signals
add wave -noupdate -group GLOBALS -radix hexadecimal /tb_mc2101/clk
add wave -noupdate -group GLOBALS -radix hexadecimal /tb_mc2101/rst_n
add wave -noupdate -group GLOBALS -radix hexadecimal /tb_mc2101/pads

#hbus signals
add wave -noupdate -group HBUS -radix hexadecimal /tb_mc2101/microcontroller/hready
add wave -noupdate -group HBUS -radix hexadecimal /tb_mc2101/microcontroller/hselram
add wave -noupdate -group HBUS -radix hexadecimal /tb_mc2101/microcontroller/hselflash
add wave -noupdate -group HBUS -radix hexadecimal /tb_mc2101/microcontroller/hselgpio
add wave -noupdate -group HBUS -radix hexadecimal /tb_mc2101/microcontroller/hseluart
add wave -noupdate -group HBUS -radix hexadecimal /tb_mc2101/microcontroller/hwrite
add wave -noupdate -group HBUS -radix hexadecimal /tb_mc2101/microcontroller/hwrdata
add wave -noupdate -group HBUS -radix hexadecimal /tb_mc2101/microcontroller/haddr
add wave -noupdate -group HBUS -radix hexadecimal /tb_mc2101/microcontroller/hrdata
add wave -noupdate -group HBUS -radix hexadecimal /tb_mc2101/microcontroller/hresp

#hslave(1) RAM signals
add wave -noupdate -group SSRAM -radix hexadecimal /tb_mc2101/microcontroller/SRAM/controller/current_state
add wave -noupdate -group SSRAM -radix hexadecimal /tb_mc2101/microcontroller/SRAM/memory/address
add wave -noupdate -group SSRAM -radix hexadecimal /tb_mc2101/microcontroller/SRAM/memory/dataIn
add wave -noupdate -group SSRAM -radix hexadecimal /tb_mc2101/microcontroller/SRAM/memory/dataOut
add wave -noupdate -group SSRAM -radix hexadecimal /tb_mc2101/microcontroller/SRAM/memory/mem
add wave -noupdate -group SSRAM -radix hexadecimal /tb_mc2101/microcontroller/SRAM/memory/readMem
add wave -noupdate -group SSRAM -radix hexadecimal /tb_mc2101/microcontroller/SRAM/memory/writeMem

#hslave(2) GPIO signals
add wave -noupdate -group GPIO -radix hexadecimal /tb_mc2101/microcontroller/GPIO/controller/current_state
add wave -noupdate -group GPIO -radix hexadecimal /tb_mc2101/microcontroller/GPIO/periph_gpio/address
add wave -noupdate -group GPIO -radix hexadecimal /tb_mc2101/microcontroller/GPIO/dataREAD
add wave -noupdate -group GPIO -radix hexadecimal /tb_mc2101/microcontroller/GPIO/dataWRITE
add wave -noupdate -group GPIO -radix hexadecimal /tb_mc2101/microcontroller/GPIO/addrLATCH
add wave -noupdate -group GPIO -radix hexadecimal /tb_mc2101/microcontroller/GPIO/latchAin
add wave -noupdate -group GPIO -radix hexadecimal /tb_mc2101/microcontroller/GPIO/shiftDin
add wave -noupdate -group GPIO -radix hexadecimal /tb_mc2101/microcontroller/GPIO/shiftDout
add wave -noupdate -group GPIO -radix hexadecimal /tb_mc2101/microcontroller/GPIO/periph_gpio/busDataIn
add wave -noupdate -group GPIO -radix hexadecimal /tb_mc2101/microcontroller/GPIO/periph_gpio/busDataOut
add wave -noupdate -group GPIO -radix hexadecimal /tb_mc2101/microcontroller/GPIO/periph_gpio/read
add wave -noupdate -group GPIO -radix hexadecimal /tb_mc2101/microcontroller/GPIO/periph_gpio/write
add wave -noupdate -group GPIO -radix hexadecimal /tb_mc2101/microcontroller/GPIO/periph_gpio/interrupt
add wave -noupdate -group GPIO -radix hexadecimal /tb_mc2101/microcontroller/GPIO/periph_gpio/core/PADDIR
add wave -noupdate -group GPIO -radix hexadecimal /tb_mc2101/microcontroller/GPIO/periph_gpio/core/PADIN
add wave -noupdate -group GPIO -radix hexadecimal /tb_mc2101/microcontroller/GPIO/periph_gpio/core/PADOUT
add wave -noupdate -group GPIO -radix hexadecimal /tb_mc2101/microcontroller/GPIO/periph_gpio/core/PADINTEN
add wave -noupdate -group GPIO -radix hexadecimal /tb_mc2101/microcontroller/GPIO/periph_gpio/core/INTTYPE0
add wave -noupdate -group GPIO -radix hexadecimal /tb_mc2101/microcontroller/GPIO/periph_gpio/core/INTTYPE1
add wave -noupdate -group GPIO -radix hexadecimal /tb_mc2101/microcontroller/GPIO/periph_gpio/core/INTSTATUS

#hslave(3) UART signals
add wave -noupdate -group UART -radix hexadecimal /tb_mc2101/microcontroller/UART/uart_ctrl/current_state
add wave -noupdate -group UART -radix hexadecimal /tb_mc2101/microcontroller/UART/uart_ctrl/chip_select 
add wave -noupdate -group UART -radix hexadecimal /tb_mc2101/microcontroller/UART/uart_periph/address
add wave -noupdate -group UART -radix hexadecimal /tb_mc2101/microcontroller/UART/uart_periph/busDataIn
add wave -noupdate -group UART -radix hexadecimal /tb_mc2101/microcontroller/UART/uart_periph/busDataOut
add wave -noupdate -group UART -radix hexadecimal /tb_mc2101/microcontroller/UART/uart_periph/read
add wave -noupdate -group UART -radix hexadecimal /tb_mc2101/microcontroller/UART/uart_periph/write
add wave -noupdate -group UART -radix hexadecimal /tb_mc2101/microcontroller/UART/uart_periph/uart_rx
add wave -noupdate -group UART -radix hexadecimal /tb_mc2101/microcontroller/UART/uart_periph/uart_tx
add wave -noupdate -group UART -radix hexadecimal /tb_mc2101/microcontroller/UART/uart_periph/interrupt
add wave -noupdate -group UART -radix hexadecimal /tb_mc2101/microcontroller/UART/uart_periph/reg_IER 
add wave -noupdate -group UART -radix hexadecimal /tb_mc2101/microcontroller/UART/uart_periph/U_IN_CTRL/interrupt_isr_code
add wave -noupdate -group UART -radix hexadecimal /tb_mc2101/microcontroller/UART/uart_periph/reg_FCR
add wave -noupdate -group UART -radix hexadecimal /tb_mc2101/microcontroller/UART/uart_periph/reg_LCR
add wave -noupdate -group UART -radix hexadecimal /tb_mc2101/microcontroller/UART/uart_periph/reg_LSR
add wave -noupdate -group UART -radix hexadecimal /tb_mc2101/microcontroller/UART/uart_periph/reg_DLL
add wave -noupdate -group UART -radix hexadecimal /tb_mc2101/microcontroller/UART/uart_periph/reg_DLM
add wave -noupdate -group UART -radix hexadecimal /tb_mc2101/microcontroller/UART/uart_periph/rx_frame 
add wave -noupdate -group UART -radix hexadecimal /tb_mc2101/microcontroller/UART/uart_periph/tx_fifo_data_out

#master interface  signals
add wave -noupdate -group AFTAB_CORE -radix hexadecimal /tb_mc2101/microcontroller/AFTAB/curr_bus_state
add wave -noupdate -group AFTAB_CORE -radix hexadecimal /tb_mc2101/microcontroller/AFTAB/coreOnInterrupt
add wave -noupdate -group AFTAB_CORE -radix hexadecimal /tb_mc2101/microcontroller/AFTAB/coreReadReq
add wave -noupdate -group AFTAB_CORE -radix hexadecimal /tb_mc2101/microcontroller/AFTAB/coreWriteReq
add wave -noupdate -group AFTAB_CORE -radix hexadecimal /tb_mc2101/microcontroller/AFTAB/core/datapathAFTAB/registerFile/rData

#run $var ns



