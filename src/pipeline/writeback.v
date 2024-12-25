`include "light_rv32i_defs.vh"

module writeback(
    input  clk,
    input  reset,

    input i_pipe_stall,

    output wire [4:0] o_RegDst,
    output wire [31:0] o_RegWrData,
    output wire     o_RegWrEn,

    // --- pipeline ---
    // former result
    input wire [31:0] i_pipe_MemData,

    // control signals
    input wire        i_pipe_MemToReg,
    input wire        i_pipe_RegWrEn,

    // pass through
    input wire [31:0] i_pipe_AluResult,
    input wire [4:0]  i_pipe_RegDst
);

    // Beq: Write PC logic
    assign o_RegDst = i_pipe_RegDst;
    assign o_RegWrData = i_pipe_MemToReg ? i_pipe_MemData : i_pipe_AluResult;
    assign o_RegWrEn = i_pipe_RegWrEn;

endmodule
