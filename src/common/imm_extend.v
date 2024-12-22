`include "light_rv32i_instr_def.h"

module imm_extend #(
    parameter INST_WIDTH = `_INST_WIDTH_
) (
    input [INST_WIDTH-1 : 0]  i_Instr,
    input [2:0] i_ExtOp,
    output wire [INST_WIDTH-1 : 0]  o_OutImm
);

    wire [INST_WIDTH-1 : 0] w_immI;
    wire [INST_WIDTH-1 : 0] w_immS;
    wire [INST_WIDTH-1 : 0] w_immB;
    wire [INST_WIDTH-1 : 0] w_immU;
    wire [INST_WIDTH-1 : 0] w_immJ;

    // assign w_immI = {20{Instr[31]}, Instr[31:20]}; // I-type
    // assign w_immS = {20{Instr[31]}, Instr[31:25], Instr[11:7]}; // S-type
    // assign w_immB = {20{Instr[31]}, Instr[7], Instr[30:25], Instr[11:8], 1'b0}; // B-type
    // assign w_immU = {Instr[31:12], 12{1'b0}}; // U-type
    // assign w_immJ = {12{Instr[31]}, Instr[19:12], Instr[20], Instr[30:21], 1'b0}; // J-type

    assign w_immI = _INST_IMM_I_(i_Instr);
    assign w_immS = _INST_IMM_S_(i_Instr);
    assign w_immB = _INST_IMM_B_(i_Instr);
    assign w_immU = _INST_IMM_U_(i_Instr);
    assign w_immJ = _INST_IMM_J_(i_Instr);

    assign o_OutImm = (i_ExtOp == 3'b000) ? w_immI :
                    (i_ExtOp == 3'b010) ? w_immS :
                    (i_ExtOp == 3'b011) ? w_immB :
                    (i_ExtOp == 3'b100) ? w_immU :
                    (i_ExtOp == 3'b101) ? w_immJ :
                    32'b0;

endmodule
