##################################################################################################
# This file updated for RV32I Pipeline Verification
##################################################################################################

# 1. Define variables
# Tên test mặc định (nếu không nhập gì thì chạy rtype)
TESTNAME    ?= rtype
TB_NAME     ?= testbench
RADIX       ?= hexadecimal
SEED        ?= 1

# 2. Define Hex Directory (Đường dẫn chứa các file hex của bạn)
HEX_DIR     = /home/vinhha/source_for_linux/RV32I_Pipeline_BranchPredict_OpenLane/hex

#==============================
all: build run

build:
	vlib work
	vmap work work
	vlog -sv -f compile.f | tee compile.log

# 3. Update Run Target
# Thêm dòng +HEX_FILE để truyền đường dẫn vào SystemVerilog
run:
	vsim -sv_seed $(SEED) -debugDB -l $(TESTNAME).log \
	-voptargs=+acc -assertdebug -c $(TB_NAME) \
	-do "log -r /*;run -all;quit" \
	+$(TESTNAME) \
	+HEX_FILE=$(HEX_DIR)/instmem_$(TESTNAME).hex

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
	@echo "** make build              : compile design"
	@echo "** make run TESTNAME=rtype : run R-Type test (default)"
	@echo "** make run TESTNAME=itype : run I-Type test"
	@echo "** make run TESTNAME=jump  : run Jump test"
	@echo "** make wave               : open waveform"
	@echo "** make clean              : clean all"
	@echo "****************************************"
	@echo ""
