PROJECT      ?= mc2101
BOARD          = pynq-z1
XILINX_PORT  ?= 3332
XILINX_HOST  ?= bordcomputer

BENDER ?= bender

CHS_ROOT ?= $(shell pwd)


VIVADOENV ?=  PROJECT=$(PROJECT)            \
              BOARD=$(BOARD)                \
              XILINX_PART=$(XILINX_PART)    \
              XILINX_BOARD=$(XILINX_BOARD)  \


VIVADO ?= vivado

#OPEN vivado in bash mode to run everything with scripts
VIVADOFLAGS ?= -nojournal -mode batch

ip-dir  := xilinx

ifeq ($(BOARD),pynq-z1)
	XILINX_PART = xc7z020clg400-1
	XILINX_BOARD = www.digilentinc.com:pynq-z1:part0:1.0
endif

create_project: 
	$(BENDER) script vivado -t simulation --no-default-target  > ${CHS_ROOT}/scripts/add_sources.tcl
	$(VIVADOENV) $(VIVADO) $(VIVADOFLAGS) -source ${CHS_ROOT}/scripts/prologue.tcl -source ${CHS_ROOT}/scripts/run.tcl


sim_uart_fifo: 
	$(VIVADO) -nojournal -mode gui -source scripts/script_uart_fifo.tcl

sim_uart_interrupt: 
	$(VIVADO) -nojournal -mode gui -source scripts/script_uart_interrupt.tcl

sim_uart_rx_core: 
	$(VIVADO) -nojournal -mode gui -source scripts/script_uart_rx_core.tcl

sim_uart_tx_core: 
	$(VIVADO) -nojournal -mode gui -source scripts/script_uart_tx_core.tcl		

sim_uart_peripheral: 
	$(VIVADO) -nojournal -mode gui -source scripts/script_uart_periph.tcl   

sim_system: 
	$(VIVADO) -nojournal -mode gui -source scripts/script_mc2101.tcl

	
update_ips:
	$(BENDER) update

gui: 
	@echo "Starting $(VIVADO) GUI"
	@$(VIVADOENV) $(VIVADO) -nojournal -mode gui $(PROJECT).xpr 

help: 
	@printf "\033[1mSystem creation\033[0m\n"
	@printf "\033[31m\tcreate_project\033[39m Create the environment to simulate the MC2101 and its peripherals. Remember to run: make -f SIM.k all file=namefiletomemory\n"
	@printf "\033[31m\tupdate_ips\033[39m Update the Bender dependencies\n"
	@printf "\033[31m\tclean\033[39m Eliminate the project and files associated with it\n"
	@printf "\033[31m\tgui\033[39m Open the GUI\n"

	@printf "\033[1mSystem simulation\033[0m\n"
	@printf "\033[31m\tsim_uart_fifo\033[39m Open the GUI, open the project and simulate the uart fifo\n"
	@printf "\033[31m\tsim_uart_interrupt\033[39m Open the GUI, open the project and simulate the uart interrupt controller \n"
	@printf "\033[31m\tsim_uart_fifo\033[39m Open the GUI, open the project and simulate the uart fifo\n"
	@printf "\033[31m\tsim_uart_rx_core\033[39m Open the GUI, open the project and simulate the uart RX\n"
	@printf "\033[31m\tsim_uart_tx_core\033[39m Open the GUI, open the project and simulate the uart TX\n"
	@printf "\033[31m\tsim_uart_peripheral\033[39m Open the GUI, open the project and simulate the uart peripheral\n"
	@printf "\033[31m\tsim_system\033[39m Open the GUI, open the project and simulate the entire system\n"



clean:
	rm -rf *.log *.jou *.str *.mif *.xci *.xpr .Xil/ $(PROJECT).cache $(PROJECT).hw $(PROJECT).ioplanning $(PROJECT).ip_user_files $(PROJECT).runs $(PROJECT).sim ./ips/BlockMemGenerator/blk_mem_gen_0.*

.PHONY: clean help
