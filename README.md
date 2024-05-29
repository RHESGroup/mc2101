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
    ├── env-riscv32.sh
    ├── Bender.lock
    ├── Bender.yml
    └── README.md

# Requirements
- VIVADO `>= 2023.1`
- RISC-V toolchain `>= 13.2.0`
- BENDER `>= 0.28.1`
### 1. Install RISC-V toolchain:
First, clone the suite of open source GNU tools for RISC-V and set the configuration:
NOTE: We are using an older version of the toolchain.
Configuration: 32-bit RISC-V core (RV32IM) with ZICSR extension
```
git clone --recursive https://github.com/riscv/riscv-gnu-toolchain
cd riscv-gnu-toolchain
./configure --prefix=/opt/riscv32 --with-arch=rv32im_zicsr --with-abi=ilp32 --with-isa-spec=2.2
make
```
Note that ilp32 specifies that int, long, and pointers are all 32-bits
After the configuration is completed, run the make. Note that make also performs an install into the path specified by --prefix: /opt/riscv32.

Then, check the files that were installed:

```
cd /opt/riscv32
tree -L 2 -d
```
Later, add  the environment variable to the .bashrc file:

```
export PATH=/opt/riscv32/bin:$PATH
```
Close the terminal, open a new one and check if the system is working:

```
riscv32-unknown-elf-gcc --version
riscv32-unknown-elf-objcopy --version
```

For further details, see the official repository: [RISC-V toolchain](https://github.com/riscv-collab/riscv-gnu-toolchain)

### 2. Install BENDER:
Follow the steps shown in the official repository: [BENDER](https://github.com/pulp-platform/bender?tab=readme-ov-file#installation).
Note: You need to install rust beforehand. Use the following command to install BENDER(once you have rust):

```
cargo install bender --version 0.28.1
```
Check that the installation was correct:
```
bender --version
```

### 3. Install VIVADO:
Vivado is downloaded from the website: [Vivado](https://www.xilinx.com/support/download.html)

It is of paramount importance to install a couple of additional dependencies before running the installation program to avoid errors and get stuck when installing Vivado. To install them:

```
sudo apt-get update -y
sudo apt-get install -y libncurses5-dev libncursesw5-dev libncurses5 libtinfo5 libtinfo-dev
```

Then, follow these steps to successfully install Vivado:
1. Go to the website, select the proper version of Vivado(The system has been tested with the
2023.1 version)
2. Once it is downloaded, you get a .tar/.gz file that has to be extracted.
3. Make a directory on the /opt/ and make it writeable:

```
sudo mkdir /opt/Xilinx
sudo chmod -R 777 /opt/Xilinx
```
4. Go to the extracted folder and run sudo ./xsetup. This is going to open the installer.
5. Complete all the requirements asked by the installer and be sure to select the installation directory as /opt/Xilinx.
6. Once this process is finished, add the following command do the .bashrc file: 

```
source /opt/Xilinx/Vivado/$Versionofvivado/settings64.sh
```
7. Close the terminal and open a new one. From now on, you can open Vivado from the terminal by writing "vivado". Note:this opens the GUI.

Moreover, you have to manually install the cable drivers for Vivado to recognize the FPGAs. To do so, you shold do the following:

```
cd /tools/Xilinx/Vivado/$Versionofvivado/data/xicom/cable_drivers/lin64/install_script/install_drivers
sudo ./intall_drivers
```
Finally, you have to add the PYNQ-Z1 board file to Vivado:

1. Go to the [PYNQ: Board files](https://pynq.readthedocs.io/en/v2.7.0/overlay_design_methodology/board_settings.html) and download the file corresponding to the PYNQ-Z1. This will download a .zip file

2. Go to:

```
cd /tools/Xilinx/Vivado/$Versionofvivado/data/boards/board_files
```
and extract the file here.

If Vivado is open, it must be restarted to load in the board files before a new project can be created.

For additional informatin regarding the installation of Vivado, please refer to [Installing Vivado, Vitis, and Digilent Board Files](https://digilent.com/reference/programmable-logic/guides/installing-vivado-and-vitis)




