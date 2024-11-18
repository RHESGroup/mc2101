PROJECT      ?= mc2101
BOARD          = pynq-z1
XILINX_PORT  ?= 3121
XILINX_HOST  ?= localhost

BENDER ?= bender

CHS_ROOT ?= $(shell pwd)


ifeq ($(BOARD),pynq-z1)
	XILINX_PART = xc7z020clg400-1
	XILINX_BOARD = www.digilentinc.com:pynq-z1:part0:1.0
endif

# Location of ip outputs
# ips := $(addprefix $(CAR_XIL_DIR)/,$(addsuffix .xci ,$(basename $(ips-names))))



VIVADOENV ?=  PROJECT=$(PROJECT)            \
              BOARD=$(BOARD)                \
              XILINX_PART=$(XILINX_PART)    \
              XILINX_BOARD=$(XILINX_BOARD)  \
              PORT=$(XILINX_PORT)           \
              HOST=$(XILINX_HOST)           \

VIVADO ?= vivado

#OPEN vivado in bash mode to run everything with scripts
VIVADOFLAGS ?= -nojournal -mode batch

ip-dir  := xilinx


update_ips:
	$(BENDER) update

gui:
	@echo "Starting $(VIVADO) GUI"
	@$(VIVADOENV) $(VIVADO) -nojournal -mode gui $(PROJECT).xpr &

generate_ips:
	$(VIVADOENV) $(VIVADO) $(VIVADOFLAGS) -source IP/BlockMemGenerator/run.tcl -source IP/ILA/run.tcl -source IP/ClkWizard/run.tcl

create_project:
	$(VIVADOENV) $(VIVADO) $(VIVADOFLAGS) -source scripts/prologue.tcl -source scripts/run.tcl

synthesis:
	$(VIVADOENV) $(VIVADO) $(VIVADOFLAGS) -source scripts/synthesis.tcl

implementation:
	$(VIVADOENV) $(VIVADO) $(VIVADOFLAGS) -source scripts/implementation.tcl

program:
	@echo "Programming board $(BOARD) ($(XILINX_PART))"
	$(VIVADOENV) $(VIVADO) $(VIVADOFLAGS) -source scripts/program.tcl

program-ILA:
	@echo "Programming board $(BOARD) ($(XILINX_PART))"
	$(VIVADOENV) $(VIVADO) -nojournal -mode gui -source scripts/program_ILA.tcl


all:
	$(VIVADOENV) $(VIVADO) $(VIVADOFLAGS) -source IP/BlockMemGenerator/run.tcl -source IP/ILA/run.tcl -source IP/ClkWizard/run.tcl -source scripts/prologue.tcl -source scripts/run.tcl -source scripts/synthesis.tcl -source scripts/implementation.tcl


help: 
	@printf "\033[1mSystem creation\033[0m\n"
	@printf "\033[31m\tgenerate_ips\033[39m Generate the IPs which will be used for the design\n"
	@printf "\033[31m\tcreate_project\033[39m Create the project and add all the source files and IPs\n"
	@printf "\033[31m\tsynthesis\033[39m Synthesize the design\n"
	@printf "\033[31m\timplementation\033[39m Run implementation and generate the bitstream\n"
	@printf "\033[31m\tprogram\033[39m Program the board with the bitstream\n"
	@printf "\033[31m\tprogram-ILA\033[39m Program the board with the bitstream and the file associated with debugging \n"
	@printf "\033[31m\tgui\033[39m Open the GUI\n"
	@printf "\033[31m\tupdate_ips\033[39m Update the bender dependencies\n"
	@printf "\033[31m\tall\033[39m Create the environment, run synthesis and implementation and obtain the bitstream.Remember: make -f FPGA.k all file=namefile\n"




clean:
	rm -rf *.log *.jou *.str *.mif *.xci *.xpr .Xil/ $(out) $(PROJECT).cache $(PROJECT).hw $(PROJECT).ioplanning $(PROJECT).ip_user_files $(PROJECT).runs $(PROJECT).sim IP/BlockMemGenerator/blk_mem_gen_0.* IP/ILA/ila_0.* Work_directory

.PHONY: clean
