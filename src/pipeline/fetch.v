`include "light_rv32i_defs.vh"

// fetch stage module
// register of the fetch stage is the program counter + Instruction

module fetch(
    input clk,
    input reset,
    
    input wire i_ctr_mux_sel,
    input wire [31:0] i_PC,
    
    output reg [31:0] o_pipe_PC,
    output reg [31:0] o_pipe_Instruction
);

    // internal signals
    reg [31:0] r_PC;
    wire [31:0] w_Instruction;

    // Instantiate instruction memory
    inst_mem #(
        .MEM_INIT_FILE("inst_mem_init.hex")
    ) instruction_memory (
        .clk(clk),
        .reset(reset),
        .i_Addr(r_PC), // Assuming word-aligned addresses
        .o_Data(w_Instruction)
    );

    // r_PC 
    always @(posedge clk or posedge reset) begin
        if (reset) begin
            r_PC <= 0;
        end else begin
            if (i_ctr_mux_sel) begin
                r_PC <= i_PC;
            end else begin
                r_PC <= r_PC + 4;
            end
        end
    end

    // o_pipe_PC and o_pipe_Instruction
    always @(posedge clk or posedge reset) begin
        if (reset) begin
            o_pipe_PC <= 0;
            o_pipe_Instruction <= 0;
        end else begin
            o_pipe_PC <= r_PC;
            o_pipe_Instruction <= w_Instruction;
        end
    end


endmodule
