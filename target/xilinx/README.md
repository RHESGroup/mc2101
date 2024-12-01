# Folder structure

    ├── IP
    │   ├── BlockMemGenerator
    │   ├── ClkWizard
    │   ├── ILA
    ├── constraints
    │   ├── physical_contraints_pynq-z1.xdc
    │   ├── timing_contraints_pynq-z1.xdc
    │── scripts
    │   ├── implementation.tcl
    │   ├── program.tcl
    │   ├── program_ILA.tcl
    │   ├── prologue.tcl
    │   ├── run.tcl
    │   ├── script_mc2101.tcl
    │   ├── sim_post_synthesis.tcl
    │   ├── synthesis.tcl
    │   ├── timing_report_syn.tcl
    ├── src
    │   ├── gpio.vhd
    │   ├── gpio_core.vhd
    │   ├── gpio_pad.vhd
    │   ├── gpio_pad_if.vhd
    │   ├── mc2101_wrapper.vhd
    │   ├── tb_gpio_pad.vhd
    │   ├── tb_mc2101.vhd
    └── FPGA.mk

# Folder description 
This folder is associated with the FPGA implementation of the MC2101 on AMD's devices.
AMD provides one useful tool for working with its FPGAs. Vivado is an integrated design environment (IDE) developed by AMD (formerly Xilinx) for designing and analyzing hardware description language (HDL) designs. It was introduced in April 2012 and has become a comprehensive tool for FPGA and SoC (System on Chip) design.

### IP
Vivado offers an IP catalog which is a centralized, searchable repository that contains a wide range of intellectual property (IP) cores. These IP cores are pre-designed and pre-verified blocks of logic that can be easily integrated into an FPGA or SoC designs to save time and effort.
For the FPGA implementation, three IPs are used:
1. Block Memory Generator IP:  [PG058 - Block Memory Generator IP Product Guide ](https://docs.amd.com/v/u/8.3-English/pg058-blk-mem-gen)
2. Clocking Wizard IP: [PG065 - Clocking Wizard IP Product Guide ](https://docs.amd.com/r/en-US/pg065-clk-wiz/Clocking-Wizard-v6.0-LogiCORE-IP-Product-Guide)
3. Integrated Logic Analyzer IP: [PG261 - Clocking Wizard IP Product Guide ](https://docs.amd.com/r/en-US/ug908-vivado-programming-debugging/ILA)

Moreover, the design instantiates one design element directly within the RTL code:
1. IOBUF: [IOBUF](https://docs.amd.com/r/en-US/ug953-vivado-7series-libraries/IOBUF)

Inside the IP folder, one can find multipe subfolders each one associated with an IP. Each subfolder includes a run.tcl script that sets the IP and configures it.

## Contraints 
XDC constraints are a combination of industry standard Synopsys Design Constraints (SDC version 1.9) and AMD proprietary physical constraints.
The design constraints define the requirements that must be met by the compilation flow in order for
the design to be functional on the board.
Designers are encourage to separate the timing constraints and physical constraints by saving them into two different files.
If the designer wants to add new contraints for a particular FPGA, he/she should follow the following name pattern:

```
Physical constraints:  physical_constraints_$BOARDNAME.xdc
Timing constraints: timing_constraints_$BOARDNAME.xdc
```
To learn more about contraints definition, refer to [UG903 - VIVADO Design Suite User Guide: Using constraints ](https://docs.amd.com/r/en-US/ug903-vivado-using-constraints)

## Scripts
### prologue.tcl
The purpose of this script is to streamline and automate the setup of a new Vivado project with predefined settings. It sets up the project environment, specifies the target FPGA part and board, sets the target language, and optimizes resource usage by setting the number of threads.
### run.tcl
This script optimizes the setup of a Vivado project by defining the current directory, selecting and reading IP cores based on the target board, sourcing additional scripts and adding constraint files and setting the top-level module for the design.
By following these steps, the script ensures that the project is properly configured with the necessary components and constraints, streamlining the project setup process
### synthesis.tcl
The purpose of this script is to streamline and automate the synthesis process by opening the project if it is not already open, setting and verifying the correct file to be used for BRAM initialization, utilizing incremental synthesis if a previous synthesis run exists to save time and running full synthesis if no previous synthesis run exists.
This ensures efficient and accurate synthesis runs, maintaining consistency and saving development time.
### implementation.tcl
This script automates the process of running implementation in Vivado, ensuring that the project is properly opened and prepared, debugging signals are identified and connected, necessary reports are generated and the implementation run is properly configured and executed.
This automation helps streamline the implementation process, saving time and ensuring consistency across runs.
### program.tcl
This script ensures the FPGA is correctly programmed with the generated bitstream by connecting to the hardware server, setting the current working directory, checking for the specific board type and performing board-specific setup, programming the FPGA with the bitstream and disconnecting from the hardware server upon successful programming.
### program_ILA.tcl
This script does the same as program.tcl, but it also includes the setting up of the debug probes. Moreover, it opens the GUI and executes the commands directly there.
### sim_post_synthesis.tcl
This script automatize the setup of a simulation environment for the mc2101 module in Vivado by checking for existing simulation sets and creating one if none exists, launching the simulation in post-synthesis functional mode, adding relevant signals to the waveform viewer for easy monitoring.
It has to be run, after synthesis complementation.
### script_mc2101.tcl
This script creates the simulation environment as well. However, it creates a behavioral simulation(before synthesis).
### timing_report_syn.tcl
This script ensures a comprehensive analysis of the design by opening the project and synthesis run, creating directories and files for storing reports, generating timing reports for the worst paths with slack less than 0 and producing a methodology report to evaluate the design against best practices.

## src
This folder includes the VHDL files modified to follow the FPGA implementation of the design.

## FPGA.mk
This Makefile is designed to automate various tasks involved in the creation, synthesis, implementation, and programming of an FPGA project using Vivado.
Run the following on the terminal to ask for more details:
```
make -f FPGA.mk help
```


