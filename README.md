<br />

# CNL_RISC-V - MC2101

`MC2101`is the first microcontroller implementation inside the CNL_RISC-V project, it is an open-source single-core microcontroller system based on a 32-bit RV32IM RISC-V core named AFTAB.<br>

AFTAB is an in-order, single-issue core with sequential stages and it has
full support for the base integer instruction set (RV32I) and multiplication instruction set
extension (RV32M). 
It implements a subset of the 1.9 privileged specification. Further informations can be found in AFTAB's repo: https://github.com/RHESGroup/aftab

For the communication with the outside world MC2101 contains at the moment two peripherals:
-   **GPIO** peripheral used to drive buttons, switches, leds and I/O pins on a board
-   **UART** peripheral used by scanf and printf functions

MC2101 contains all the necessary to perform RTL simulations as well as FPGA synthesis


# Repository folder structure

    .
    ├── docs
    │   ├── MC2101 User Manual.pdf
    ├── hw
    │   ├── gpio
    │   ├── include
    │   ├── ssram
    │   ├── uart
    │   ├── core_bus_wrap.vhd
    │   ├── mc2101.vhd
    ├── sw
    │   ├── apps
    │   ├── build
    │   ├── libs
    │   ├── ref
    │   ├── utils
    │   ├── cmake_configure.aftab.gcc.sh
    │   ├── CMakeLists.txt
    │   ├── README.md
    │── target
    │   ├── sim
    │   ├── xilinx
    ├── util
    │── env-riscv32.sh
    │── Bender.lock
    │── Bender.yml
    └── README.md
