##################################################################################################
#This file created by Huy Nguyen
#Updated date: 6/30/2024
##################################################################################################

#Define variables
TESTNAME 	?= i2c_standard_test
TB_NAME 	?= testbench
RADIX			?= hexadecimal
SEED      ?= 1

#==============================
all: build run

build:
	vlib work
	vmap work work
	vlog -sv -f compile.f | tee compile.log
run:
	vsim -sv_seed $(SEED) -debugDB -l $(TESTNAME).log -voptargs=+acc -assertdebug -c $(TB_NAME) -do "log -r /*;run -all;" +$(TESTNAME)
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
	@echo "** make all  : compile and run simulation"
	@echo "** make wave : open waveform"
	@echo "** make clean: clean all compiled data"
	@echo "****************************************"
	@echo ""
