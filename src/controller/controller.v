`include "light_rv32i_defs.vh"

module controller #(
    parameter INST_WIDTH = `_INST_WIDTH_
) (
    input [INST_WIDTH-1:0] i_Instrunction,

    output wire [2:0] o_ExtOp,
    output wire o_Alu1Src,
    output wire [1:0] o_Alu2Src,
    output wire [3:0] o_AluCtr,
    output wire o_MemToReg,
    output wire o_RegWrEn,
    output wire o_MemWrEn,
    output wire o_Branch,
    output wire o_Jump
);

    // 单周期，不需要状态机

    // 控制信号
    wire [6:0] w_Opcode = `_INST_OPCODE_(i_Instrunction);
    wire [2:0] w_Func3 = `_INST_FUNC3_(i_Instrunction);
    wire [6:0] w_Func7 = `_INST_FUNC7_(i_Instrunction);

    assign o_Branch = (w_Opcode == `_OPCODE_B_TYPE_)? (w_Func3 == `_FUNCT3_BEQ_) : 0;

    assign o_Jump = (w_Opcode == `_OPCODE_J_TYPE_)? 1 : 0;

    assign o_Alu1Src = (w_Opcode == `_OPCODE_J_TYPE_)? 1 : 0;

    assign o_Alu2Src = (w_Opcode == `_OPCODE_R_TYPE_)? `_ALU_SRCB_REG2_ :
                       (w_Opcode == `_OPCODE_B_TYPE_)? `_ALU_SRCB_REG2_ :
                       (w_Opcode == `_OPCODE_J_TYPE_)? `_ALU_SRCB_FOUR_ : `_ALU_SRCB_IMM_;

    assign o_AluCtr = (w_Opcode == `_OPCODE_R_TYPE_)? ((w_Func7 == `_FUNCT7_LOGIC_) ? {1'b0, w_Func3} : ((w_Func7 == _FUNCT7_SUB_) ? `_ALU_SUB_ : `_ALU_ADD_)) :
                      (w_Opcode == `_OPCODE_I_TYPE_ || w_Opcode == `_OPCODE_LW_ || w_Opcode == `_OPCODE_SW_)? `_ALU_ADD_ :
                      (w_Opcode == `_OPCODE_B_TYPE_)? ((w_Func3 == `_FUNCT3_BEQ_) ? `_ALU_SUB_ : `_ALU_SLT_) :
                      (w_Opcode == `_OPCODE_J_TYPE_)? `_ALU_ADD_ : 
                      (w_Opcode == `_OPCODE_LUI_)? `_ALU_SRCB_ : 
                      4'b0;

    assign o_MemToReg = (w_Opcode == `_OPCODE_LW_)? 1 : 0;

    assign o_RegWrEn = (w_Opcode == `_OPCODE_SW_ || w_Opcode == `_OPCODE_BEQ_) ? 0 : 1;

    assign o_MemWrEn = (w_Opcode == `_OPCODE_SW_)? 1 : 0;

    assign o_ExtOp = (w_Opcode == `_OPCODE_LUI_)? `_EXT_U_ :
                     (w_Opcode == `_OPCODE_I_TYPE_ || w_Opcode == `_OPCODE_LW_) ? `_EXT_I_ :
                     (w_Opcode == `_OPCODE_SW_)? `_EXT_S_ :
                     (w_Opcode == `_OPCODE_B_TYPE_)? `_EXT_B_ :
                     (w_Opcode == `_OPCODE_J_TYPE_)? `_EXT_J_ : 
                     `_EXT_NONE_;

endmodule