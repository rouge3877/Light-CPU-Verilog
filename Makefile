IVERILOG = iverilog
IVERILOG_FLAGS = -g2005-sv -I./src/include

# Simulation command
VVP = vvp

# GTKWave command
WAVE = gtkwave

# SRC files, get all files in src directory and its subdirectories
SRC = $(shell find src -name "*.v")


alu: src/common/alu.v src/common/adder.v test/testbench/alu_tb.v
	$(IVERILOG) $(IVERILOG_FLAGS) src/common/alu.v src/common/adder.v test/testbench/alu_tb.v -o alu -s alu_tb
	$(VVP) alu
	$(WAVE) alu_tb.vcd &

# 测试整体的cpu，将src下的所有文件编译，cpu_top.v为顶层文件
simple_cpu: $(SRC) test/testbench/simple_cpu_tb.v
	$(IVERILOG) $(IVERILOG_FLAGS) $(SRC) test/testbench/simple_cpu_tb.v -o simple_cpu_tb -s simple_cpu_tb
	$(VVP) simple_cpu_tb
	$(WAVE) simple_cpu_tb.vcd &

%:
	@echo "Running test $@..."
	cat test/testcase/$@.asm | ./scripts/assembler.py > inst_mem_init.hex
	$(IVERILOG) $(IVERILOG_FLAGS) $(SRC) test/testbench/simple_cpu_tb.v -o simple_cpu_tb -s simple_cpu_tb
	$(VVP) simple_cpu_tb
	$(WAVE) simple_cpu_tb.vcd &

clean:
	rm -f alu alu_tb simple_cpu_tb simple_cpu_tb.vcd