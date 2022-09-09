# CNL_RISC-V - MC2101

MC2101 is the first microcontroller implementation inside the CNL_RISC-V project, it is an open-source single-core microcontroller system based on a 32-bit RV32IM RISC-V core named AFTAB.<br>

AFTAB is an in-order, single-issue core with sequential stages and it has
full support for the base integer instruction set (RV32I) and multiplication instruction set
extension (RV32M). 
It implements a subset of the 1.9 privileged specification. Further informations can be found in AFTAB's repo: https://github.com/RHESGroup/aftab

For the communication with the outside world MC2101 contains at the moment two peripherals:
-   **GPIO** peripheral used to drive buttons, switches, leds and I/O pins on a board
-   **UART** peripheral used by scanf and printf functions

MC2101 contains all the necessary to perform RTL simulations as well as FPGA synthesis

## Documentation and Requirements

All the detailed documentation, as well as requirements for installing software toolchain and 
simulate MC2101 is in the manual, under the folder /doc.

## Running simulations

The software is built using CMake.
Create a build folder somewhere, e.g. in the `/sw` folder:

    mkdir build

Copy the `cmake-configure.aftab.gcc.sh` bash script to the build folder.
This script can be found in the `/sw` subfolder of the repository.

Modify the `cmake-configure.aftab.gcc.sh` script to your needs and execute it inside the build folder.
This will setup everything to perform simulations using ModelSim.

Inside the build folder, execute

    make vcompile

to compile the RTL libraries using ModelSim.

To run a simulation in the ModelSim GUI, use

    make helloworld.vsim

To run simulations in the ModelSim console, use

    make helloworld.vsimc

Replace `helloworld` with the test/application you want to run.

## FPGA

MC2101 can be synthesized and run on a DE1-SoC board. Look at `/fpga` subfolder for more informations.

## Disclaimer and Copyright

The project is under development.  
All code and material is released under LGPL v3.0 ( https://www.gnu.org/licenses/lgpl-3.0.txt ).
Copyright (C) 2022 CINI Cybersecurity National Laboratory.