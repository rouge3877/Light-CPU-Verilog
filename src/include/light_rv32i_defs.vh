`ifndef _LIGHT_RV32I_DEFS_VH_
`define _LIGHT_RV32I_DEFS_VH_

//======================================================
//  RV32I Minimal Subset: 常量定义头文件
//  Light-CPU Project
//======================================================
//
// 本头文件主要包含：
//  1) 指令各字段在 32 位指令中的位置
//  2) opcode / funct3 / funct7 的取值定义
//  3) 各指令的编码宏
//
//======================================================

//------------------------------------------------------
// 0) 基本常量定义
//------------------------------------------------------
`define _TRUE_  1
`define _FALSE_ 0
`define _ENABLE_ 1
`define _DISABLE_ 0
`define _MACHINE_WIDTH_ 32
`define _MEM_ADDR_WIDTH_ `_MACHINE_WIDTH_
`define _MEM_DATA_WIDTH_ `_MACHINE_WIDTH_
`define _REG_ADDR_WIDTH_ 5
`define _REG_DATA_WIDTH_ `_MACHINE_WIDTH_
`define _REG_NUMBER_ (1 << `_REG_ADDR_WIDTH_)

//------------------------------------------------------
// 1) 通用指令字段在指令字中的位置
//------------------------------------------------------
// RISC-V 指令 32 位拆分如下：
//   31:25   24:20   19:15   14:12   11:7   6:0
//   funct7  rs2     rs1     funct3  rd     opcode
//
//   I-type / S-type / B-type / U-type / J-type
//   也都是通过这 5-6 个字段的组合来形成。
//------------------------------------------------------
`define _INST_WIDTH_       `_MACHINE_WIDTH_
`define _OPCODE_LSB_       0
`define _OPCODE_MSB_       6
`define _RD_LSB_           7
`define _RD_MSB_           11
`define _FUNCT3_LSB_       12
`define _FUNCT3_MSB_       14
`define _RS1_LSB_          15
`define _RS1_MSB_          19
`define _RS2_LSB_          20
`define _RS2_MSB_          24
`define _FUNCT7_LSB_       25
`define _FUNCT7_MSB_       31
//------------------------------------------------------
// 1.1) 定义一些常用的宏，用于提取指令字段
`define _INST_OPCODE_(x)   x[`_OPCODE_MSB_:`_OPCODE_LSB_]
`define _INST_RD_(x)       x[`_RD_MSB_:`_RD_LSB_]
`define _INST_FUNCT3_(x)   x[`_FUNCT3_MSB_:`_FUNCT3_LSB_]
`define _INST_RS1_(x)      x[`_RS1_MSB_:`_RS1_LSB_]
`define _INST_RS2_(x)      x[`_RS2_MSB_:`_RS2_LSB_]
`define _INST_FUNCT7_(x)   x[`_FUNCT7_MSB_:`_FUNCT7_LSB_]
//------------------------------------------------------
// 1.2) 定义一些常用的宏，用于提取立即数字段
`define _INST_IMM_I_(x)    {{20{x[`_FUNCT7_MSB_]}}, x[`_FUNCT7_MSB_:`_RS2_LSB_]}
`define _INST_IMM_S_(x)    {{20{x[`_FUNCT7_MSB_]}}, x[`_FUNCT7_MSB_:`_FUNCT7_LSB_], x[`_RD_MSB_:`_RD_LSB_]}
`define _INST_IMM_B_(x)    {{20{x[`_FUNCT7_MSB_]}}, x[`_RD_LSB_], x[`_FUNCT7_MSB_-1:`_FUNCT7_LSB_], x[`_RD_MSB_:`_RD_LSB_], 1'b0}
`define _INST_IMM_U_(x)    {x[`_FUNCT7_MSB_: `_FUNCT3_LSB_], 12'b0}
`define _INST_IMM_J_(x)    {{12{x[`_FUNCT7_MSB_]}}, x[19:12], x[20], x[30:21], 1'b0}


//------------------------------------------------------
// 2) opcode 取值定义 (7 bits)
//------------------------------------------------------
// 参照规格说明第 10 章指令二进制编码表
`define _OPCODE_R_TYPE_    7'b0110011  // ADD, SUB, AND, OR, XOR, SLT
`define _OPCODE_I_TYPE_    7'b0010011  // ADDI
`define _OPCODE_B_TYPE_    7'b1100011  // BEQ
`define _OPCODE_J_TYPE_    7'b1101111  // JAL
`define _OPCODE_LW_        7'b0000011  // LW
`define _OPCODE_SW_        7'b0100011  // SW
`define _OPCODE_LUI_       7'b0110111  // LUI

//------------------------------------------------------
// 3) funct3 取值定义 (3 bits)
//------------------------------------------------------
`define _FUNCT3_ADD_SUB_   3'b000  // ADD / SUB 使用相同 funct3，但需区分 funct7
`define _FUNCT3_SLT_       3'b010
`define _FUNCT3_AND_       3'b111
`define _FUNCT3_OR_        3'b110
`define _FUNCT3_XOR_       3'b100
//
`define _FUNCT3_ADDI_      3'b000  // 与 ADD/SUB 同，但这在 I-type 中表征 ADDI
//
`define _FUNCT3_BEQ_       3'b000
//
`define _FUNCT3_LW_SW_     3'b010  // LW 与 SW 的 funct3 都是 010

//------------------------------------------------------
// 4) funct7 取值定义 (7 bits) - R-type 中使用
//------------------------------------------------------
`define _FUNCT7_ADD_       7'b0000000
`define _FUNCT7_SUB_       7'b0100000
`define _FUNCT7_LOGIC_     7'b0000000 // AND / OR / XOR / SLT 都是 0000000


//------------------------------------------------------
// 5) ALU 操作码定义及源操作数选择
//------------------------------------------------------
// ALU 操作码定义
`define _ALU_ADD_  4'b0000
`define _ALU_SUB_  4'b1000
`define _ALU_AND_  {1'b0, `_FUNCT3_AND_}
`define _ALU_OR_   {1'b0, `_FUNCT3_OR_}
`define _ALU_XOR_  {1'b0, `_FUNCT3_XOR_}
`define _ALU_SLT_  {1'b0, `_FUNCT3_SLT_}

`define _ALU_SRCB_ 4'b1111

// ALU 源操作数选择
`define _ALU_SRCB_REG2_ 2'b00
`define _ALU_SRCB_IMM_  2'b01
`define _ALU_SRCB_FOUR_ 2'b10


// ALU src forward
`define _ALU_SRCB_SRCREG_ 2'b00
`define _ALU_SRCB_WBDATA_  2'b01
`define _ALU_SRCB_EXMDATA_ 2'b10



//------------------------------------------------------
// 6) Extention 定义
//------------------------------------------------------
`define _EXT_I_  3'b000
`define _EXT_U_  3'b001
`define _EXT_S_  3'b010
`define _EXT_B_  3'b011
`define _EXT_J_  3'b100
`define _EXT_NONE_ 3'b111

//------------------------------------------------------
// 6) 定义通用寄存器编号
//------------------------------------------------------
`define _REG_X0_  5'd0
`define _REG_X1_  5'd1
`define _REG_X2_  5'd2
`define _REG_X3_  5'd3
`define _REG_X4_  5'd4
`define _REG_X5_  5'd5
`define _REG_X6_  5'd6
`define _REG_X7_  5'd7
`define _REG_X8_  5'd8
`define _REG_X9_  5'd9
`define _REG_X10_ 5'd10
`define _REG_X11_ 5'd11
`define _REG_X12_ 5'd12
`define _REG_X13_ 5'd13
`define _REG_X14_ 5'd14
`define _REG_X15_ 5'd15
`define _REG_X16_ 5'd16
`define _REG_X17_ 5'd17
`define _REG_X18_ 5'd18
`define _REG_X19_ 5'd19
`define _REG_X20_ 5'd20
`define _REG_X21_ 5'd21
`define _REG_X22_ 5'd22
`define _REG_X23_ 5'd23
`define _REG_X24_ 5'd24
`define _REG_X25_ 5'd25
`define _REG_X26_ 5'd26
`define _REG_X27_ 5'd27
`define _REG_X28_ 5'd28
`define _REG_X29_ 5'd29
`define _REG_X30_ 5'd30
`define _REG_X31_ 5'd31


//------------------------------------------------------
// 7) 其他可选定义
//------------------------------------------------------
// `define _MEM_SIZE- (1024*1024) // 例如 1MB 内存
// `define _ALIGNED_ACCESS_ 1    // 是否启用对齐检查
`define _INST_MEM_SIZE_ `_INST_WIDTH_ * 1024 / 8
`define _INST_MEM_ACCESS_OVERRANGE_ 0 // 检查内存访问是否越界
`define _DATA_MEM_SIZE_ `_MEM_DATA_WIDTH_ * 1024 / 8
`define _DATA_MEM_ACCESS_OVERRANGE_ 0 // 检查内存访问是否越界


`endif // _LIGHT_RV32I_DEFS_VH_
