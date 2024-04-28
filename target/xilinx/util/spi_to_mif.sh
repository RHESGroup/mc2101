#!/bin/bash

# **************************************************************************************
#	Filename:	spi_to_mif.sh
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
#	#script to convert from spi_stim file (used by vsim) to mif file
#
# **************************************************************************************

if [ $# -lt 1 ]
then
	echo "usage: $0 program_name"
	exit 1
fi

SW_ROOT_DIR=../sw
TEST_PROGRAMS_ROOT_DIR=$SW_ROOT_DIR/build/apps/test_mc2101
PROGRAM_S19="$TEST_PROGRAMS_ROOT_DIR/$1/$1.s19"
MIF_FILE=./utils/program.mif

#find s19 file used by pulpino tools to build the spi_stim.txt file
if [ ! -f $PROGRAM_S19 ]
then
	echo "$PROGRAM_S19 not found!"
	exit 1
fi

#create spi_stim file using pulpino s19toslm.py script
$SW_ROOT_DIR/utils/s19toslm.py $PROGRAM_S19

echo "spi_stim.txt file has been generated"

ls spi_stim.txt

#removing useless autogenerated files
rm -rf *.slm 

#####################################
########ram physical size############
##################################### 
RAM_ADDR_WIDTH=14
RAM_SIZE=$((2**$RAM_ADDR_WIDTH))

#####################################
#virtual address to physical address#
##################################### 
VIRTUAL_DATA_RAM_START=$((2**20))
PHYSICAL_DATA_RAM_START=$((2**13))


#mif file description
echo "--DATE: $(date)" > $MIF_FILE
echo "--THIS FILE SHOULD NOT BE MODIFIED" >> $MIF_FILE
echo "--THIS FILE CONTAINS THE CODE FOR FPGA MEMORY INITIALIZATION" >> $MIF_FILE
echo "--" >> $MIF_FILE
echo "--MEMORY CONFIGURATION:" >> $MIF_FILE
echo "--	ADDRESS WIDTH=$RAM_ADDR_WIDTH" >> $MIF_FILE
echo "--	DATA    WIDTH=8" >> $MIF_FILE
echo "--	MEMORY  WORDS=$RAM_SIZE" >> $MIF_FILE
echo "--" >> $MIF_FILE
echo "--PROGRAM NAME: $1" >> $MIF_FILE
echo "--" >> $MIF_FILE

#mif format configuration
echo "WIDTH=8;" >> $MIF_FILE
echo "DEPTH=$RAM_SIZE;" >> $MIF_FILE 
echo "ADDRESS_RADIX=UNS;" >> $MIF_FILE
echo "DATA_RADIX=HEX;" >> $MIF_FILE
echo "CONTENT BEGIN" >> $MIF_FILE

#convertion from spi_stim.txt to mif format

nAddr=0
cByte=""
iStart=0
while read line
do
	cByte=$(echo $line | cut -d'_' -f2)
	cAddr=$(echo $line | cut -d'_' -f1)
	#convert address to integer
	cAddr=$(( 16#$cAddr ))
	#convert virtual address to physical
	if [ $cAddr -ge $VIRTUAL_DATA_RAM_START ]
	then
	    cAddr=$(( $cAddr-$VIRTUAL_DATA_RAM_START+$PHYSICAL_DATA_RAM_START))
	fi
	#mif content format "address : value;"
	echo "      $cAddr : ${cByte:6:2};">> $MIF_FILE
	cAddr=$(( $cAddr+1 )) 
	echo "      $cAddr : ${cByte:4:2};">> $MIF_FILE
	cAddr=$(( $cAddr+1 ))
	echo "      $cAddr : ${cByte:2:2};">> $MIF_FILE
	cAddr=$(( $cAddr+1 ))
	echo "      $cAddr : ${cByte:0:2};">> $MIF_FILE
done < ./spi_stim.txt

echo "END;" >> $MIF_FILE

echo "mif file has been generated"

ls utils/program.mif

rm spi_stim.txt
