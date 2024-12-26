`timescale 1ns / 1ps

module simple_cpu_tb();

    // clk and reset
    reg clk;
    reg reset;

    always begin
        #5 clk = ~clk;
    end

    initial begin
        clk = 0;
        reset = 0;
        #5 reset = 1;
        #10 reset = 0;
    end

    // Instantiate the CPU_TOP
    cpu_top uut (
        .clk(clk),
        .reset(reset)
    );

    // finish after 200 cycles
    initial begin
        #100 $finish;
    end


    initial begin
        $dumpfile("simple_cpu_tb.vcd");
        $dumpvars(0, simple_cpu_tb);
    end

    // print reg file each cycle
    integer i;
    always @(posedge clk) begin
        $display("------------------------Cycle %0d------------------------", $time);
        
        $display("PC = %0d", uut.u_fetch.o_pipe_PC);
        $display("Instruction = %0h", uut.u_fetch.o_pipe_Instruction);
        for(i = 0; i < 5; i = i + 1) begin
            $display("reg[%0d] = %0d", i, uut.u_decode.u_reg_file.reg_array[i]);
        end

        $display("--------------------------------------------------------");
    end

endmodule