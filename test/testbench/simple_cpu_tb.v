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
        #500 $finish;
    end


    initial begin
        $dumpfile("simple_cpu_tb.vcd");
        $dumpvars(0, simple_cpu_tb);
    end

    // print reg file each cycle
    integer i;
    always @(posedge clk) begin
        $display("~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~Cycle %0d~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~", $time);
        $display("PC = %0x | Instruction = %0h", uut.u_fetch.o_pipe_PC, uut.u_fetch.o_pipe_Instruction);
        // print reg file as a table to make it easier to read
        $display("───────────────────────────────────────────────────────────────────────────────────────────────");
        for (i = 0; i < 32; i = i + 4) begin
            $display("│ reg[%2d] = %8x \t │ reg[%2d] = %8x \t │ reg[%2d] = %8x \t │ reg[%2d] = %8x │",
                 i, uut.u_decode.u_reg_file.reg_array[i], i+1, uut.u_decode.u_reg_file.reg_array[i+1], 
                 i+2, uut.u_decode.u_reg_file.reg_array[i+2], i+3, uut.u_decode.u_reg_file.reg_array[i+3]);
        end
        $display("───────────────────────────────────────────────────────────────────────────────────────────────");
        $display("\n");
    end

endmodule