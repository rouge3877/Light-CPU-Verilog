`include "light_rv32i_defs.vh"

module execute(
    input  clk,
    input  reset,
    
    input [3:0] i_ctr_AluCtr,
    input i_ctr_Alu1Src,
    input [1:0] i_ctr_Alu2Src,

    input wire [31:0] i_pipe_PC,
    input wire [31:0] i_pipe_Imm,
    input wire [31:0] i_pipe_Reg1Data,
    input wire [31:0] i_pipe_Reg2Data,
    input wire [4:0]  i_pipe_RegDst,

    input wire        i_pipe_Alu1Src,
    input wire [1:0]  i_pipe_Alu2Src,
    input wire [3:0]  i_pipe_AluCtr,
    input wire        i_pipe_MemToReg,
    input wire        i_pipe_RegWrEn,
    input wire        i_pipe_MemWrEn,
    input wire        i_pipe_Branch,
    input wire        i_pipe_Jump
    
    
    output reg [31:0] o_pipe_TargetAddr,
    output reg [31:0] o_pipe_AluResult,
    output reg o_pipe_Zero,
    output reg [31:0] o_pipe_Reg2Data,
    output reg [4:0]  o_pipe_RegDst,

    output reg       o_pipe_MemToReg,
    output reg       o_pipe_RegWrEn,
    output reg       o_pipe_MemWrEn,
    output reg       o_pipe_Branch,
    output reg       o_pipe_Jump

);

    // Instantiate alu
    wire [31:0] w_a, w_b, w_Result;
    wire [3:0] w_AluCtr;
    wire w_cf, w_zf, w_of, w_sf;

    alu u_alu (
        .i_a      (w_a),
        .i_b      (w_b),
        .i_AluCtr (w_AluCtr),
        .o_Result (w_Result),
        .o_cf     (w_cf),
        .o_zf     (w_zf),
        .o_of     (w_of),
        .o_sf     (w_sf)
    );


    

    
