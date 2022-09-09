# FPGA

This folder contains everything needed to synthesize MC2101 microcontroller on Terasic's DE1-SoC board.

# Requirements

Synthesis has been tested with **Quartus Prime 21.1 Lite Edition** running on a Linux machine, some tests have been done also with older verion of Quartus software (version 18 running on Windows for instance) but there is no guarantee that is going to work with any other version|machine without modifications to some scripts.

The evaluation board used is the **Terasic's DE1-SoC** with the following FPGA's specifications:
-   FAMILY: Cyclone V
-   DEVICE: 5CSEMA5F31C6

If you intend to use the uart peripheral (scanf & print functions) then you need also a **USB to UART Bridge Controller**.

If you intend to use the USB to UART Bridge controller on Windows it's higly recommended to install his [driver](https://www.silabs.com/developers/usb-to-uart-bridge-vcp-drivers?tab=downloads).

# Makefile commands available

It is possible to synthesize the microcontroller and program the fpga by using the make commands defined in the [Makefile](./Makefile).
The make commands allow you to perform the following operations:
-   **Full compilation flow**: (design hdl compilation) -> (place & route) -> (static timing analysis) -> (assembler) -> (fpga config. file)
-   **Memory update**: update the fpga config. file with the application to be run by the microcontroller
-   **Configure the FPGA**

## Full compilation flow

The complete compilation flow (time consuming task) needs to be done only when the hdl design of the microcontroller is modified.
For doing that just call

    make compile_design

and wait for some minutes to complete all steps..

After this process a *mc2101.sof* file in [ouput_files](./output_files/) folder is created, this file is used by Quartus programmer to configure the FPGA.


## Memory update

In order to run an application on MC2101 there are 2 steps to be done:
-   **build the target application**: the application must be located in the [sw/apps/test_mc2101](../sw/apps/test_mc2101/) folder, there are already two demos ready to be used. The application must be compiled folliwing the instructions defined in the [sw/README](../sw/README.md)

-   **generate the memory initialization file**, used by Quartus to initialize the memory content of the synthesized ram and **update mc2101.sof configuration file**. Just call `make update_ram`, the default target application is defined in the [Makefile](./Makefile) as TARGET_APP, so if you intend to run your custom application make sure to run the command like this: `make TARGET_APP=your_app_name update_ram`

## Configure the FPGA

To configure the FPGA with the mc2101.sof file:

-   Make sure the DE1-SoC is connected to your PC with the USB-Blaster cable
-   Make sure the UART to USB is wired to the correct board's pins, *see pin assignent section below*

call:

    make program_fpga

If you see a message like this: "No JTAG device available" means the USB-Blaster cable is not connected or not recognized, in this situation you should try to program the fpga directly by using Quartus Programmer tools in Quartus gui, in this case i suggest to run Quartus as administrator because it's possible that usb blaster device can be accessed only by super user.

# PIN assignment

MC2101 includes a set of build-in peripherals like UART and GPIOs.
-   *UART TX* is connected to the GPIO Connection 0[1] of the board Expansion Headers
-   *UART RX* is connected to the GPIO Connection 0[3] of the board Expansion Headers
-   *GPIO[0-9]* are connected to LEDR[0-9]
-   *GPIO[10-19]* are connected to SW[0-9]
-   *GPIO[20-22]* are connected to KEY[1-3]
-   *RESET* is connected to KEY0
-   *CLOCK* is connected to the CLOCK_50(50MHz) line of the clock distribution on the DE1-SoC.

More informations on the pins can be found in [DE1-SoC user manual](https://www.google.com/url?sa=i&rct=j&q=&esrc=s&source=web&cd=&cad=rja&uact=8&ved=0CAMQw7AJahcKEwjo6Ze3x4f6AhUAAAAAHQAAAAAQAg&url=http%3A%2F%2Fwww.ee.ic.ac.uk%2Fpcheung%2Fteaching%2Fee2_digital%2FDE1-SoC_User_manual.pdf&psig=AOvVaw1HUMjhOmZAMx6oPnrUV0CZ&ust=1662807670601964)