`include "light_rv32i_defs.vh"

module forward(
    input wire [4:0]  i_forward_IDEX_Reg1,
    input wire [4:0]  i_forward_IDEX_Reg2,

    input wire [4:0]  i_forward_EXM_RegDst,
    input wire [4:0]  i_forward_EXM_Reg2,

    input wire        i_forward_EXM_RegWrEn,
    input wire        i_forward_EXM_MemWrEn,

    input wire [4:0]  i_forward_MWB_RegDst,
    input wire        i_forward_MWB_RegWrEn,

    output wire [1:0] o_forward_SlctA,
    output wire [1:0] o_forward_SlctB,
    output wire       o_forward_SlctWBData
);

    // ALU src forward
    // `define _ALU_SRCB_SRCREG_ 2'b00
    // `define _ALU_SRCB_WBDATA_  2'b01
    // `define _ALU_SRCB_EXMDATA_ 2'b10
    
    assign o_forward_SlctA = 
        {(i_forward_EXM_RegWrEn && (i_forward_EXM_RegDst == i_forward_IDEX_Reg1) 
                                && (i_forward_EXM_RegDst != 0)), 
         (i_forward_MWB_RegWrEn && (i_forward_MWB_RegDst == i_forward_IDEX_Reg1) 
                                && (i_forward_MWB_RegDst != 0)
                                && (i_forward_EXM_RegDst != i_forward_IDEX_Reg1))};

    assign o_forward_SlctB = 
        {(i_forward_EXM_RegWrEn && (i_forward_EXM_RegDst == i_forward_IDEX_Reg2) 
                                && (i_forward_EXM_RegDst != 0)), 
         (i_forward_MWB_RegWrEn && (i_forward_MWB_RegDst == i_forward_IDEX_Reg2) 
                                && (i_forward_MWB_RegDst != 0)
                                && (i_forward_EXM_RegDst != i_forward_IDEX_Reg2))};

    assign o_forward_SlctWBData = 
        i_forward_MWB_RegWrEn && (i_forward_MWB_RegDst == i_forward_EXM_Reg2) 
                              && i_forward_EXM_MemWrEn
                              && (i_forward_MWB_RegDst != 0);

endmodule