CHS_ROOT ?= $(shell pwd)
BENDER	 ?= bender -d $(CHS_ROOT)

include mc2101.mk

all:
	@$(MAKE) chs-all

%-all:
	@$(MAKE) chs-$*-all

nonfree-%:
	@$(MAKE) chs-nonfree-$*

clean-%:
	@$(MAKE) chs-clean-$*
