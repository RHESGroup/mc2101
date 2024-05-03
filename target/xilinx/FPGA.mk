PROJECT      ?= mc2101
BOARD          = pynq-z1
XILINX_PORT  ?= 3332
XILINX_HOST  ?= bordcomputer

BENDER ?= bender

CHS_ROOT ?= $(shell pwd)


ifeq ($(BOARD),pynq-z1)
	XILINX_PART = xc7z020clg400-1
	XILINX_BOARD = www.digilentinc.com:pynq-z1:part0:1.0
endif

# Location of ip outputs
# ips := $(addprefix $(CAR_XIL_DIR)/,$(addsuffix .xci ,$(basename $(ips-names))))

out := out
bit := $(out)/$(PROJECT)_top_xilinx.bit
mcs := $(out)/$(PROJECT)_top_xilinx.mcs
BIT ?= $(bit)

VIVADOENV ?=  PROJECT=$(PROJECT)            \
              BOARD=$(BOARD)                \
              XILINX_PART=$(XILINX_PART)    \
              XILINX_BOARD=$(XILINX_BOARD)  \
              PORT=$(XILINX_PORT)           \
              HOST=$(XILINX_HOST)           \
              BIT=$(BIT)

VIVADO ?= vivado

#OPEN vivado in bash mode to run everything with scripts
VIVADOFLAGS ?= -nojournal -mode batch

ip-dir  := xilinx

all: $(bit)

$(bit): $(ips)
	$(BENDER) script vivado -t fpga  > ${CHS_ROOT}/scripts/add_sources.tcl
	@mkdir -p $(out)
	$(VIVADOENV) $(VIVADO) $(VIVADOFLAGS) -source ips/BlockMemGenerator/run.tcl -source scripts/prologue.tcl   -source scripts/run.tcl
	cp $(PROJECT).runs/impl_1/$(PROJECT)* ./$(out)


$(ips): 
	@echo "Generating IP $(basename $@)"
	cd $(ip-dir)/$(basename $@) && $(MAKE) clean && $(VIVADOENV) VIVADO="$(VIVADO)" $(MAKE)
	cp $(ip-dir)/$(basename $@)/$(basename $@).srcs/sources_1/ip/$(basename $@)/$@ $@


update_ips:
	$(BENDER) update

gui:
	@echo "Starting $(VIVADO) GUI"
	@$(VIVADOENV) $(VIVADO) -nojournal -mode gui $(PROJECT).xpr &

program:
	@echo "Programming board $(BOARD) ($(XILINX_PART))"
	$(VIVADOENV) $(VIVADO) $(VIVADOFLAGS) -source scripts/program.tcl

clean:
	rm -rf *.log *.jou *.str *.mif *.xci *.xpr .Xil/ $(out) $(PROJECT).cache $(PROJECT).hw $(PROJECT).ioplanning $(PROJECT).ip_user_files $(PROJECT).runs $(PROJECT).sim

.PHONY: clean
