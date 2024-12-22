`include "light_rv32i_defs.vh"

module alu #(
    parameter DATA_WIDTH = `_REG_DATA_WIDTH_
) (
    input  wire [DATA_WIDTH-1:0] i_a,       // 操作数A
    input  wire [DATA_WIDTH-1:0] i_b,       // 操作数B
    input  wire [3:0]            i_AluCtr,  // 控制信号，和 RV32I 规范一致
    output wire [DATA_WIDTH-1:0] o_Result,  // 运算结果
    output wire                  o_cf,      // Carry Flag
    output wire                  o_zf,      // Zero Flag
    output wire                  o_of,      // Overflow Flag
    output wire                  o_sf       // Sign Flag
);

    wire [DATA_WIDTH-1:0] w_sum;            // 加法/减法结果
    wire                  w_carry_out;      // 最后的进位

    // 基本门实现的加法器（可综合）
    adder u_adder (
        .i_a   (i_a),
        .i_b   (i_AluCtr == `_ALU_SUB_ ? ~i_b : i_b), // 若是 SUB 指令，b 取反（补码）
        .i_c (i_AluCtr == `_ALU_SUB_), // SUB 的初始进位为 1
        .o_s   (w_sum),
        .o_c(w_carry_out)
    );

    // 控制信号
    assign o_Result = (i_AluCtr == `_ALU_ADD_) ? w_sum :        
                      (i_AluCtr == `_ALU_SUB_) ? w_sum :        // SUB
                      (i_AluCtr == `_ALU_SLT_) ? (i_a < i_b) :  // SLT
                      (i_AluCtr == `_ALU_XOR_) ? (i_a ^ i_b) :  // XOR
                      (i_AluCtr == `_ALU_OR_)  ? (i_a | i_b) :  // OR
                      (i_AluCtr == `_ALU_AND_) ? (i_a & i_b) :  // AND
                                                 i_b;           // 直接输出 B

    // 标志位计算
    assign o_cf = w_carry_out;                              // 进位标志
    assign o_zf = (o_Result == {DATA_WIDTH{1'b0}});         // 零标志
    assign o_of = (i_a[DATA_WIDTH-1] == i_b[DATA_WIDTH-1] && o_Result[DATA_WIDTH-1] != i_a[DATA_WIDTH-1]); // 溢出标志
    assign o_sf = o_Result[DATA_WIDTH-1];                   // 符号标志

endmodule
