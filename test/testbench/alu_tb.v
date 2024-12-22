`timescale 1ns / 1ps

module alu_tb;

    // Parameters
    parameter DATA_WIDTH = 32;

    // Inputs
    reg [DATA_WIDTH-1:0] i_a;
    reg [DATA_WIDTH-1:0] i_b;
    reg [3:0]            i_aluctr;

    // Outputs
    wire [DATA_WIDTH-1:0] o_result;
    wire                  o_cf;
    wire                  o_zf;
    wire                  o_of;
    wire                  o_sf;

    // Instantiate the ALU
    alu #(
        .DATA_WIDTH(DATA_WIDTH)
    ) uut (
        .i_a(i_a),
        .i_b(i_b),
        .i_aluctr(i_aluctr),
        .o_result(o_result),
        .o_cf(o_cf),
        .o_zf(o_zf),
        .o_of(o_of),
        .o_sf(o_sf)
    );

    // Testbench
    initial begin
        // Initialize inputs
        i_a = 0;
        i_b = 0;
        i_aluctr = 0;

        // Monitor outputs
        $monitor("Time=%0t i_a=%h i_b=%h i_aluctr=%b o_result=%h o_cf=%b o_zf=%b o_of=%b o_sf=%b", 
                 $time, i_a, i_b, i_aluctr, o_result, o_cf, o_zf, o_of, o_sf);

        // Test ADD
        i_a = 32'h00000010;
        i_b = 32'h00000020;
        i_aluctr = 4'b0000; // `_ALU_ADD_`
        #10;
        if (o_result !== 32'h00000030) $display("ADD Test Failed");
        else $display("ADD Test Passed");

        // Test SUB
        i_a = 32'h00000030;
        i_b = 32'h00000010;
        i_aluctr = 4'b0001; // `_ALU_SUB_`
        #10;
        if (o_result !== 32'h00000020) $display("SUB Test Failed");
        else $display("SUB Test Passed");

        // Test AND
        i_a = 32'h0000000F;
        i_b = 32'h000000F0;
        i_aluctr = 4'b0010; // `_ALU_AND_`
        #10;
        if (o_result !== 32'h00000000) $display("AND Test Failed");
        else $display("AND Test Passed");

        // Test OR
        i_a = 32'h0000000F;
        i_b = 32'h000000F0;
        i_aluctr = 4'b0011; // `_ALU_OR_`
        #10;
        if (o_result !== 32'h000000FF) $display("OR Test Failed");
        else $display("OR Test Passed");

        // Test XOR
        i_a = 32'h0000000F;
        i_b = 32'h000000F0;
        i_aluctr = 4'b0100; // `_ALU_XOR_`
        #10;
        if (o_result !== 32'h000000FF) $display("XOR Test Failed");
        else $display("XOR Test Passed");

        // Test SLT
        i_a = 32'h00000010;
        i_b = 32'h00000020;
        i_aluctr = 4'b0101; // `_ALU_SLT_`
        #10;
        if (o_result !== 32'h00000001) $display("SLT Test Failed");
        else $display("SLT Test Passed");

        // Finish simulation
        $finish;
    end

    initial begin
        $dumpfile("alu_tb.vcd");
        $dumpvars(0, alu_tb);
    end

endmodule