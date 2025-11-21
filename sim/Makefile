#################################################################################################
#This file created by Huy Nguyen (modified)
#Updated date: 2025-11-21
##################################################################################################

# Define variables
TESTNAME ?=               # testcase name, e.g. add / sub
TB_NAME  ?= testbench
RADIX    ?= hexadecimal

# Compute PLUSARG: if TESTNAME is empty, no +test=... will be added
ifeq ($(strip $(TESTNAME)),)
    PLUSARG =
    LOGFILE = default.log
else
    PLUSARG = +test=$(TESTNAME)
    LOGFILE = $(TESTNAME).log
endif

#==============================
all: build run

build:
	vlib work
	vmap work work
	vlog -sv -f compile.f | tee compile.log

run:
	vsim -debugDB -l $(LOGFILE) -voptargs=+acc -assertdebug -c $(TB_NAME) \
	     $(PLUSARG) -do "log -r /*; run -all; quit"

wave:
	vsim -i -view vsim.wlf -do "add wave vsim:/$(TB_NAME)/*; radix -$(RADIX)" &

clean:
	rm -rf work
	rm -rf vsim.dbg
	rm -rf *.ini
	rm -rf *.log
	rm -rf *.wlf
	rm -rf transcript

help:
	@echo ""
	@echo "****************************************"
	@echo "** make build: compile the design and testbench"
	@echo "** make run  : run simulation"
	@echo "**"
	@echo "** Example:"
	@echo "**   make run TESTNAME=add   -> passes +test=add to vsim"
	@echo "**   make run TESTNAME=sub   -> passes +test=sub"
	@echo "**   make run                -> no +test, use default testbench behavior"
	@echo "**"
	@echo "** make wave : open waveform"
	@echo "** make clean: clean all compiled data"
	@echo "****************************************"
	@echo ""

