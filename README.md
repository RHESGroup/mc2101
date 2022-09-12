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

## Simulate MC2101

It is possible to run simulations of the entire system in ModelSim with already defined test programs like [hello_world](./sw/apps/test_string_lib/hello_world/hello_world.c) or with any application you write. <br>
The problem in running MC2101 applications on ModelSim lies in very long simualtion times (order of ms) and the fact that some behaviors (like interrupts or scanf) are difficult to simulate, for these reasons more advanced applications should be tested only on fpga.<br>


### Running simulations

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

To run a simulation of the MC2101 microcontroller using the ModelSim GUI, use

    make helloworld.vsim

It is also possible to run simulations using ModelSim Cosole, but in this case only AFTAB core is tested. Use: 

    make helloworld.vsimc

Replace `helloworld` with the test/application you want to run.

## Testing on FPGA

MC2101 can be synthesized and run applications on a DE1-SoC board.<br>
Applications that are supposed to run on FPGA should be written in the `sw/apps/test_mc2101` folder so that all make commands defined in `/fpga/Makefile` can fully automate the synthesis process with your application.<br> 
Look at `/fpga` subfolder for more informations.

## Disclaimer and Copyright

The project is under development.  
All code and material is released under LGPL v3.0 ( https://www.gnu.org/licenses/lgpl-3.0.txt ).
Copyright (C) 2022 CINI Cybersecurity National Laboratory.
