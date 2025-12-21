##################################################################################################
# RV32I Pipeline Verification - QuestaSim
# Auto-generate HEX from assembly.S
##################################################################################################

# ==============================
# 1. Variables
# ==============================
TESTNAME ?= nhap
TB_NAME  ?= testbench
RADIX    ?= hexadecimal
SEED     ?= 1

# ==============================
# 2. Paths
# ==============================
HEX_DIR := /c/Users/VINH\ HA/Documents/Documents/tailieu/TAILIEUMONHOC/DOAN2/git/final4/RV32I_Pipeline_BranchPredict_OpenLane/hex

ASM_FILE := ../assembly.S

ELF_FILE := program.elf
HEX_OUT  := $(HEX_DIR)/instmem_nhap.hex

# ==============================
# 3. RISC-V Toolchain
# ==============================
RISCV_GCC     := riscv-none-elf-gcc
RISCV_OBJCOPY := riscv-none-elf-objcopy

# ==============================
# 4. Default target
# ==============================
all: run

# ==============================
# 5. Generate HEX from ASM
# ==============================
gen_hex:
	@echo "=================================================="
	@echo " Generating HEX from $(ASM_FILE)"
	@echo "=================================================="
	$(RISCV_GCC) \
	  -march=rv32i \
	  -mabi=ilp32 \
	  -nostdlib \
	  -Ttext=0x0 \
	  $(ASM_FILE) \
	  -o $(ELF_FILE)

	$(RISCV_OBJCOPY) \
	  -O verilog \
	  $(ELF_FILE) \
	  $(HEX_OUT)

	@echo "✔ Generated $(HEX_OUT)"

# ==============================
# 6. Build RTL
# ==============================
build: gen_hex
	vlib work
	vmap work work
	vlog -sv -f compile.f | tee compile.log

# ==============================
# 7. Run Simulation
# ==============================
run: build
	@echo ""
	@echo "Running test: $(TESTNAME)"
	@echo "Using HEX   : $(HEX_OUT)"
	@echo ""
	vsim -sv_seed $(SEED) -debugDB -l $(TESTNAME).log \
	-voptargs=+acc -assertdebug -c $(TB_NAME) \
	-do "log -r /*;run -all;quit" \
	+$(TESTNAME) \
	+HEX_FILE=$(HEX_OUT)

# ==============================
# 8. Open Waveform
# ==============================
wave:
	vsim -i -view vsim.wlf \
	-do "add wave vsim:/$(TB_NAME)/*; radix -$(RADIX)" &

# ==============================
# 9. Clean
# ==============================
clean:
	rm -rf work vsim.dbg *.ini *.log *.wlf transcript $(ELF_FILE)

# ==============================
# 10. Help
# ==============================
help:
	@echo ""
	@echo "****************************************"
	@echo "** make run        : ASM → HEX → SIM"
	@echo "** make build      : ASM → HEX → COMPILE"
	@echo "** make wave       : open waveform"
	@echo "** make clean      : clean all"
	@echo "****************************************"
	@echo ""
