IVERILOG = iverilog
IVERILOG_FLAGS = -g2005-sv -I./src/include

# Simulation command
VVP = vvp

# GTKWave command
WAVE = gtkwave


alu: src/common/alu.v src/common/adder.v test/testbench/alu_tb.v
	$(IVERILOG) $(IVERILOG_FLAGS) src/common/alu.v src/common/adder.v test/testbench/alu_tb.v -o alu -s alu_tb
	$(VVP) alu
	$(WAVE) alu_tb.vcd &
