`include "light_rv32i_defs.vh"

module decode(
    input clk,
    input reset,

    input i_pipe_stall,

    input wire i_RegWrEn,   // 假设用于指示写回使能
    input wire [4:0] i_RegDst, // 用于写回目的寄存器
    input wire [31:0] i_RegWrData, // 用于写回数据
    

    // --- pipeline ---
    // former result
    input wire [31:0] i_pipe_PC,
    input wire [31:0] i_pipe_Instruction,

    // this result
    output reg [31:0] o_pipe_Imm,
    output reg [31:0] o_pipe_Reg1Data,
    output reg [31:0] o_pipe_Reg2Data,

    // pass through
    output reg [4:0]  o_pipe_RegDst,
    output reg [31:0] o_pipe_PC,

    // control signals
    output reg       o_pipe_Alu1Src,
    output reg [1:0] o_pipe_Alu2Src,
    output reg [3:0] o_pipe_AluCtr,
    output reg       o_pipe_MemToReg,
    output reg       o_pipe_RegWrEn,
    output reg       o_pipe_MemWrEn,
    output reg       o_pipe_Branch,
    output reg       o_pipe_Jump

);

// Instantiate controller
wire [2:0] w_ExtOp;
wire       w_Alu1Src;
wire [1:0] w_Alu2Src;
wire [3:0] w_AluCtr;
wire       w_MemToReg;
wire       w_RegWrEn;
wire       w_MemWrEn;
wire       w_Branch;
wire       w_Jump;

controller  u_controller (
    .i_Instrunction(i_pipe_Instruction),
    .o_ExtOp       (w_ExtOp),
    .o_Alu1Src     (w_Alu1Src),
    .o_Alu2Src     (w_Alu2Src),
    .o_AluCtr      (w_AluCtr),
    .o_MemToReg    (w_MemToReg),
    .o_RegWrEn     (w_RegWrEn),
    .o_MemWrEn     (w_MemWrEn),
    .o_Branch      (w_Branch),
    .o_Jump        (w_Jump)
);


// Instantiate register file

wire [31:0] w_Reg1Data, w_Reg2Data;
wire [4:0] w_Reg1, w_Reg2, w_RegDst;

// 提取指令字段
assign w_Reg1 = `_INST_RS1_(i_pipe_Instruction);
assign w_Reg2 = `_INST_RS2_(i_pipe_Instruction);
// assign w_RegDst  = `_INST_RD_(i_pipe_Instruction);
assign w_RegDst = i_RegDst;

reg_file u_reg_file (
    .clk        (clk),
    .reset      (reset),
    .i_Reg1Addr (w_Reg1),
    .i_Reg2Addr (w_Reg2),
    .o_Reg1Data (w_Reg1Data),
    .o_Reg2Data (w_Reg2Data),

    // 假设此处暂不处理写回数据，就给默认值
    .i_RegWrAddr (w_RegDst),
    .i_RegWrData (i_RegWrData),
    .i_RegWrEn   (i_RegWrEn)
);

// Instantiate immediate extend

wire [31:0] w_imm;

imm_extend u_imm_extend (
    .i_Instr (i_pipe_Instruction),
    .i_ExtOp (w_ExtOp),
    .o_OutImm(w_imm)
);

// 组合输出到下一流水级
always @(posedge clk or posedge reset) begin
    if (reset) begin
        o_pipe_PC       <= 32'b0;
        o_pipe_Imm      <= 32'b0;
        o_pipe_Reg1Data <= 32'b0;
        o_pipe_Reg2Data <= 32'b0;
        o_pipe_RegDst   <= 5'b0;

        o_pipe_Alu1Src  <= 1'b0;
        o_pipe_Alu2Src  <= 2'b0;
        o_pipe_AluCtr   <= 4'b0;
        o_pipe_MemToReg <= 1'b0;
        o_pipe_RegWrEn  <= 1'b0;
        o_pipe_MemWrEn  <= 1'b0;
        o_pipe_Branch   <= 1'b0;
        o_pipe_Jump     <= 1'b0;
    end else if (!i_pipe_stall) begin
        o_pipe_PC       <= i_pipe_PC;
        o_pipe_Imm      <= w_imm;
        o_pipe_Reg1Data <= w_Reg1Data;
        o_pipe_Reg2Data <= w_Reg2Data;
        o_pipe_RegDst   <= `_INST_RD_(i_pipe_Instruction);

        o_pipe_Alu1Src  <= w_Alu1Src;
        o_pipe_Alu2Src  <= w_Alu2Src;
        o_pipe_AluCtr   <= w_AluCtr;
        o_pipe_MemToReg <= w_MemToReg;
        o_pipe_RegWrEn  <= w_RegWrEn;
        o_pipe_MemWrEn  <= w_MemWrEn;
        o_pipe_Branch   <= w_Branch;
        o_pipe_Jump     <= w_Jump;

    end
end

endmodule