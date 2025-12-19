##################################################################################################
# RV32I Pipeline Verification - QuestaSim
##################################################################################################

# ==============================
# 1. Variables
# ==============================
TESTNAME ?= rtype
TB_NAME  ?= testbench
RADIX    ?= hexadecimal
SEED     ?= 1

# ==============================
# 2. HEX directory (KHÔNG đổi)
# ==============================
HEX_DIR := /c/Users/VINH\ HA/Documents/Documents/tailieu/TAILIEUMONHOC/DOAN2/source_final1/RV32I_Pipeline_BranchPredict_OpenLane/hex

# ==============================
# 3. Targets
# ==============================
all: build run

build:
	vlib work
	vmap work work
	vlog -sv -f compile.f | tee compile.log

run:
	@echo "Running test: $(TESTNAME)"
	@echo "HEX file: $(HEX_DIR)/instmem_$(TESTNAME).hex"
	vsim -sv_seed $(SEED) -debugDB -l $(TESTNAME).log \
	-voptargs=+acc -assertdebug -c $(TB_NAME) \
	-do "log -r /*;run -all;quit" \
	+$(TESTNAME) \
	+HEX_FILE=$(HEX_DIR)/instmem_$(TESTNAME).hex

wave:
	vsim -i -view vsim.wlf -do "add wave vsim:/$(TB_NAME)/*; radix -$(RADIX)" &

clean:
	rm -rf work vsim.dbg *.ini *.log *.wlf transcript

help:
	@echo ""
	@echo "****************************************"
	@echo "** make build                     : compile design"
	@echo "** make run TESTNAME=rtype        : run R-Type test"
	@echo "** make run TESTNAME=itype        : run I-Type test"
	@echo "** make run TESTNAME=branch       : run Branch test"
	@echo "** make wave                      : open waveform"
	@echo "** make clean                     : clean all"
	@echo "****************************************"
	@echo ""
