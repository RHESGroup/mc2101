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

all: 
	$(BENDER) script vivado -t simulation  > ${CHS_ROOT}/scripts/add_sources.tcl
	$(VIVADOENV) $(VIVADO) $(VIVADOFLAGS) -source ${CHS_ROOT}/ips/BlockMemGenerator/run.tcl -source ${CHS_ROOT}/../xilinx/scripts/prologue.tcl -source ${CHS_ROOT}/scripts/run.tcl


sim_uart_fifo: 
	$(VIVADO) -nojournal -mode gui -source scripts/script_uart_fifo.tcl

sim_uart_interrupt: 
	$(VIVADO) -nojournal -mode gui -source scripts/script_uart_interrupt.tcl

sim_uart_peripheral: 
	$(VIVADO) -nojournal -mode gui -source scripts/script_uart_periph.tcl

sim_uart_rx_core: 
	$(VIVADO) -nojournal -mode gui -source scripts/script_uart_rx_core.tcl

sim_uart_tx_core: 
	$(VIVADO) -nojournal -mode gui -source scripts/script_uart_tx_core.tcl		
	


update_ips:
	$(BENDER) update

gui:
	@echo "Starting $(VIVADO) GUI"
	@$(VIVADOENV) $(VIVADO) -nojournal -mode gui $(PROJECT).xpr &

clean:
	rm -rf *.log *.jou *.str *.mif *.xci *.xpr .Xil/ $(PROJECT).cache $(PROJECT).hw $(PROJECT).ioplanning $(PROJECT).ip_user_files $(PROJECT).runs $(PROJECT).sim

.PHONY: clean
