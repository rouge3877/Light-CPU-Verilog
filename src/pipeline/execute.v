`include "light_rv32i_defs.vh"

module execute(
    input  clk,
    input  reset,
    
    // --- forwarding ---
    input wire [1:0]  i_forward_SlctA,
    input wire [1:0]  i_forward_SlctB,
    input wire [31:0] i_forward_WBData,
    input wire [31:0] i_forward_EXMData,


    // --- pipeline ---
    // former result
    input wire [31:0] i_pipe_PC,
    input wire [31:0] i_pipe_Imm,
    input wire [31:0] i_pipe_Reg1Data,
    input wire [31:0] i_pipe_Reg2Data,
    input wire [4:0]  i_pipe_RegDst,
    input wire [4:0]  i_pipe_Reg2,
    input wire        i_pipe_Alu1Src,
    input wire [1:0]  i_pipe_Alu2Src,
    input wire [3:0]  i_pipe_AluCtr,

    // control signals
    input wire        i_pipe_MemToReg,
    input wire        i_pipe_RegWrEn,
    input wire        i_pipe_MemWrEn,
    input wire        i_pipe_Branch,
    input wire        i_pipe_Jump,
    
    // this result
    output reg [31:0] o_pipe_TargetAddr,
    output reg [31:0] o_pipe_AluResult,
    output reg        o_pipe_Zero,

    // pass through
    output reg [31:0] o_pipe_Reg2Data,
    output reg [4:0]  o_pipe_RegDst,
    output reg [4:0]  o_pipe_Reg2,

    // control signals
    output reg       o_pipe_MemToReg,
    output reg       o_pipe_RegWrEn,
    output reg       o_pipe_MemWrEn,
    output reg       o_pipe_Branch,
    output reg       o_pipe_Jump

);

    // 1. Instantiate alu
    wire [31:0] w_AluInA, w_AluInB, w_AluResult;
    wire [3:0] w_AluCtr;
    wire w_AluCf;

    wire [31:0] w_BusA, w_BusB;

    alu u_alu (
        .i_a      (w_AluInA),
        .i_b      (w_AluInB),
        .i_AluCtr (w_AluCtr),
        .o_Result (w_AluResult),
        .o_cf     (),
        .o_zf     (w_AluZf),
        .o_of     (),
        .o_sf     ()
    );

    assign w_BusA = i_forward_SlctA == `_ALU_SRCB_SRCREG_ ? i_pipe_Reg1Data :
                    i_forward_SlctA == `_ALU_SRCB_WBDATA_ ? i_forward_WBData :
                    i_forward_SlctA == `_ALU_SRCB_EXMDATA_ ? i_forward_EXMData :
                     i_pipe_Reg1Data;
    
    assign w_BusB = i_forward_SlctB == `_ALU_SRCB_SRCREG_ ? i_pipe_Reg2Data :
                    i_forward_SlctB == `_ALU_SRCB_WBDATA_ ? i_forward_WBData :
                    i_forward_SlctB == `_ALU_SRCB_EXMDATA_ ? i_forward_EXMData :
                     i_pipe_Reg2Data;


    // alu input A mux:
    assign w_AluInA = i_pipe_Alu1Src ? i_pipe_PC : w_BusA;

    // alu input B mux:
    assign w_AluInB = i_pipe_Alu2Src == `_ALU_SRCB_IMM_ ? i_pipe_Imm :
                     i_pipe_Alu2Src == `_ALU_SRCB_REG2_ ? w_BusB :
                     i_pipe_Alu2Src == `_ALU_SRCB_FOUR_ ? 32'h00000004 :
                     32'h00000000;

    //---- alu overflow flag/ sign flag/ carry flag is unused in this project ----
    assign w_AluCtr = i_pipe_AluCtr;


    // 2. Instantiate adder
    wire [31:0] w_AdderResult, w_AdderInA, w_AdderInB;

    adder u_adder (
        .i_a (w_AdderInA),
        .i_b (w_AdderInB),
        .i_c (1'b0),
        .o_s (w_AdderResult),
        .o_c ()
    );

    // adder input and output, carry is unused
    assign w_AdderInA = i_pipe_PC;
    assign w_AdderInB = i_pipe_Imm;


    always @(posedge clk or posedge reset) begin
        if (reset) begin
            o_pipe_AluResult <= 0;
            o_pipe_Zero <= 0;
            o_pipe_TargetAddr <= 0;

            o_pipe_Reg2Data <= 0;
            o_pipe_RegDst <= 0;
            o_pipe_Reg2 <= 0;
            o_pipe_MemToReg <= 0;
            o_pipe_RegWrEn <= 0;
            o_pipe_MemWrEn <= 0;
            o_pipe_Branch <= 0;
            o_pipe_Jump <= 0;
        end else begin
            o_pipe_AluResult <= w_AluResult;
            o_pipe_Zero <= w_AluZf;
            o_pipe_TargetAddr <= w_AdderResult;

            o_pipe_Reg2Data <= i_pipe_Reg2Data;
            o_pipe_RegDst <= i_pipe_RegDst;
            o_pipe_Reg2 <= i_pipe_Reg2;
            o_pipe_MemToReg <= i_pipe_MemToReg;
            o_pipe_RegWrEn <= i_pipe_RegWrEn;
            o_pipe_MemWrEn <= i_pipe_MemWrEn;
            o_pipe_Branch <= i_pipe_Branch;
            o_pipe_Jump <= i_pipe_Jump;
        end
    end


endmodule
