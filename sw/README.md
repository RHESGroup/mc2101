# General Overview
## Prerequisites

A suitable compiler for the RISC-V ISA must be available.

For the basic RV32I instruction set also the official toolchain can be used.

## Setup

The software compilation flow is based on CMake. A version of CMake >= 2.8.0 is
required, but a version greater than 3.1.0 is recommended due to support for
ninja.

CMake uses out-of-source builds which means you will need a separate build
folder for the software, e.g. `build`

    mkdir build

Then switch to the build folder and copy the cmake template configuration
script, called `cmake-configure.aftab.gcc.sh`
Choose, copy, modify and then execute this script. It will setup the build
environment for you.

Now you are ready to start compiling software!

## Compiling

Switch to the build folder and compile the application you are interested in:

    make applicationName

### For Modelsim:
This command will compile the application and generate stimuli for RTL
simulation using ModelSim.


To compile the RTL using ModelSim, use

    make vcompile

### For Vivado:
Once "make applicationName" is run, one has to follow the steps shown in the "Generating .coe file" part.


## Executing

To execute an application again CMake can be used. Switch to the build folder
and execute

    make applicationName.vsim

to start ModelSim in GUI mode.

To use console mode and final checks of results (if available), use

    make applicationName.vsimc

## Generating .coe file
The .coe file corresponds to the file that includes the code that is uploaded into the memory(the Block RAM in this case) when the target is an AMD's device. The current flow starts from the generation of a file called "spi_stim.txt" starting from the .s19 file; then, the .txt file is translated into a .mif file and a .coe file. The VIVADO Block Memory Generator IP uses a .coe file to initialize the values of the memory. Thus, you should run the following once you have compiled the application(make applicationName):
```
chmod 777 /util/spi_to_mif.sh
source spi_to_mif.sh applicationName SUBFOLDERS'PATHOFapplicationName
```
For example, to create the .coe for testing the uart:
```
source spi_to_mif.sh test_uart test_sys_lib/test_uart
```
To create the .coe for testing the board in general:
```
source spi_to_mif.sh board_test_general test_mc2101/board_test_general
```
Note: run this commands in the directory MC2101/util

On the other hand, for simulation, a dual-port RAM memory is described in VHDL which reads the "spi_stim.txt" to initialize the memory. Similarly, the previous commands update the values of the spi_stim.txt file with the values associated with a particular application; thus, these commands should be used before simulating a new application.

# Applications
## How to add a new application

CMake uses the concept of `CMakeLists.txt` files in each directory that is
managed by the tool. Those files give instructions to the tool about which
applications exist and which files belong to it.

An application is defined like this in a `CMakeLists.txt` file:

    add_application(helloworld helloworld.c)


If an application consists of multiple source files it has be defined like
this:

    set(SOURCES main.c helper.c)
    add_application(helloworld "${SOURCES}")


For ease-of-use we recommend that each application has its own source
directory. Use the `add_subdirectory` macro of CMake to let the tool know about
folder structures. Those macros are put in the parent folders until you hit a
folder that is already managed by CMake. Each of the folders needs to have a
`CMakeLists.txt` file.

All applications need to have their own build folders. This means that if you
want to declare multiple applications in the same source folders, you have to
make sure they do not share the same build folder. This can be done by the
optional argument `SUBDIR` for `add_application`

    add_application(helloworld helloworld.c SUBDIR "hello"))

The command above would put the application helloworld in a subdirectory called
`hello` in the `/build` folder structure.


# CMake Targets

Each application supports the following targets:

* ${NAME}: Compile the application and generate all stimuli for simulation
* ${NAME}.vsim: Start modelsim in GUI mode
* ${NAME}.vsimc: Start modelsim in console
* ${NAME}.elf: Compile the application and generate the elf file
* ${NAME}.read: Perform an objdump of the binary and save it as NAME.read
* ${NAME}.list: Perform an objdump of the binary with -D option (i.e., with data) and save it as NAME.lst
