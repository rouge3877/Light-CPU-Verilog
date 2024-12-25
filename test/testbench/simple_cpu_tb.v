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
        #200 $finish;
    end


    initial begin
        $dumpfile("simple_cpu_tb.vcd");
        $dumpvars(0, simple_cpu_tb);
    end

endmodule