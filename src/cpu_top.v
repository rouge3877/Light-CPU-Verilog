`include "light_rv32i_defs.vh"

module cpu_top(
    input wire clk,
    input wire reset
);

    // Wires between pipeline stages
    // Fetch -> Decode
    wire        w_fetch_ctl_mux_sel;
    wire [31:0] w_fetch_PC;
    wire [31:0] w_fetch_Instruction;

    // Decode -> Execute
    wire [31:0] w_decode_Imm;
    wire [31:0] w_decode_Reg1Data;
    wire [31:0] w_decode_Reg2Data;
    wire [4:0]  w_decode_RegDst;
    wire [31:0] w_decode_PC;
    wire [4:0]  w_decode_Reg1;
    wire [4:0]  w_decode_Reg2;
    wire        w_decode_Alu1Src;
    wire [1:0]  w_decode_Alu2Src;
    wire [3:0]  w_decode_AluCtr;
    wire        w_decode_MemToReg;
    wire        w_decode_RegWrEn;
    wire        w_decode_MemWrEn;
    wire        w_decode_Branch;
    wire        w_decode_Jump;

    // Execute -> Access Mem
    wire [31:0] w_execute_TargetAddr;
    wire [31:0] w_execute_AluResult;
    wire        w_execute_Zero;
    wire [31:0] w_execute_Reg2Data;
    wire [4:0]  w_execute_RegDst;
    wire [4:0]  w_execute_Reg2;
    wire        w_execute_MemToReg;
    wire        w_execute_RegWrEn;
    wire        w_execute_MemWrEn;
    wire        w_execute_Branch;
    wire        w_execute_Jump;

    // Access Mem -> Writeback
    wire        w_mem_ctl_NextPC;
    wire [31:0] w_mem_MemData;
    wire [31:0] w_mem_AluResult;
    wire [4:0]  w_mem_RegDst;
    wire        w_mem_MemToReg;
    wire        w_mem_RegWrEn;

    // Writeback -> Decode (Register Write Info)
    wire [4:0]  w_wb_RegDst;
    wire [31:0] w_wb_RegWrData;
    wire        w_wb_RegWrEn;


    // =========================================================================
    // Forwarding Unit
    // =========================================================================

    wire [1:0] w_forward_SlctA;
    wire [1:0] w_forward_SlctB;
    wire       w_forward_SlctWBData;

    forward u_forward (
        .i_forward_IDEX_Reg1(w_decode_Reg1),
        .i_forward_IDEX_Reg2(w_decode_Reg2),

        .i_forward_EXM_RegDst(w_execute_RegDst),
        .i_forward_EXM_Reg2(w_execute_Reg2),

        .i_forward_EXM_RegWrEn(w_execute_RegWrEn),
        .i_forward_EXM_MemWrEn(w_execute_MemWrEn),

        .i_forward_MWB_RegDst(w_mem_RegDst),
        .i_forward_MWB_MemWrEn(w_mem_RegWrEn),

        .o_forward_SlctA(w_forward_SlctA),
        .o_forward_SlctB(w_forward_SlctB),
        .o_forward_SlctWBData(w_forward_SlctWBData)
);


    // =========================================================================
    // Fetch Stage
    // =========================================================================
    fetch u_fetch (
        .clk             (clk),
        .reset           (reset),
        .i_ctr_mux_sel   (w_mem_ctl_NextPC),       // Branch/Jump decision from Mem stage
        .i_PC            (w_execute_TargetAddr),   // Target address from Execute
        .o_pipe_PC       (w_fetch_PC),
        .o_pipe_Instruction(w_fetch_Instruction)
    );

    // =========================================================================
    // Decode Stage
    // =========================================================================
    decode u_decode (
        .clk             (clk),
        .reset           (reset),
        // Writeback signals for register file
        .i_RegWrEn       (w_wb_RegWrEn),
        .i_RegDst        (w_wb_RegDst),
        .i_RegWrData     (w_wb_RegWrData),

        // Input from Fetch
        .i_pipe_PC       (w_fetch_PC),
        .i_pipe_Instruction(w_fetch_Instruction),

        // Outputs for Execute
        .o_pipe_Imm      (w_decode_Imm),
        .o_pipe_Reg1Data (w_decode_Reg1Data),
        .o_pipe_Reg2Data (w_decode_Reg2Data),
        .o_pipe_RegDst   (w_decode_RegDst),
        .o_pipe_PC       (w_decode_PC),
        .o_pipe_Reg1     (w_decode_Reg1),
        .o_pipe_Reg2     (w_decode_Reg2),

        // Control signals for Execute
        .o_pipe_Alu1Src  (w_decode_Alu1Src),
        .o_pipe_Alu2Src  (w_decode_Alu2Src),
        .o_pipe_AluCtr   (w_decode_AluCtr),
        .o_pipe_MemToReg (w_decode_MemToReg),
        .o_pipe_RegWrEn  (w_decode_RegWrEn),
        .o_pipe_MemWrEn  (w_decode_MemWrEn),
        .o_pipe_Branch   (w_decode_Branch),
        .o_pipe_Jump     (w_decode_Jump)
    );

    // =========================================================================
    // Execute Stage
    // =========================================================================
    execute u_execute (
        .clk             (clk),
        .reset           (reset),

        // Forwarding signals
        .i_forward_SlctA (w_forward_SlctA),
        .i_forward_SlctB (w_forward_SlctB),
        .i_forward_WBData(w_wb_RegWrData),
        .i_forward_EXMData(w_execute_AluResult),

        // Input from Decode
        .i_pipe_PC       (w_decode_PC),
        .i_pipe_Imm      (w_decode_Imm),
        .i_pipe_Reg1Data (w_decode_Reg1Data),
        .i_pipe_Reg2Data (w_decode_Reg2Data),
        .i_pipe_RegDst   (w_decode_RegDst),
        .i_pipe_Reg2     (w_decode_Reg2),
        .i_pipe_Alu1Src  (w_decode_Alu1Src),
        .i_pipe_Alu2Src  (w_decode_Alu2Src),
        .i_pipe_AluCtr   (w_decode_AluCtr),
        .i_pipe_MemToReg (w_decode_MemToReg),
        .i_pipe_RegWrEn  (w_decode_RegWrEn),
        .i_pipe_MemWrEn  (w_decode_MemWrEn),
        .i_pipe_Branch   (w_decode_Branch),
        .i_pipe_Jump     (w_decode_Jump),

        // Outputs for Access Mem
        .o_pipe_TargetAddr(w_execute_TargetAddr),
        .o_pipe_AluResult (w_execute_AluResult),
        .o_pipe_Zero      (w_execute_Zero),
        .o_pipe_Reg2Data  (w_execute_Reg2Data),
        .o_pipe_RegDst    (w_execute_RegDst),
        .o_pipe_Reg2      (w_execute_Reg2),
        .o_pipe_MemToReg  (w_execute_MemToReg),
        .o_pipe_RegWrEn   (w_execute_RegWrEn),
        .o_pipe_MemWrEn   (w_execute_MemWrEn),
        .o_pipe_Branch    (w_execute_Branch),
        .o_pipe_Jump      (w_execute_Jump)
    );

    // =========================================================================
    // Access Memory Stage
    // =========================================================================
    access_mem u_access_mem (
        .clk             (clk),
        .reset           (reset),

        // Forwarding signals
        .i_forward_Slct  (w_forward_SlctWBData),
        .i_forward_Data  (w_wb_RegWrData),

        // Branch/Jump control for fetch
        .o_ctl_NextPC    (w_mem_ctl_NextPC),

        // Input from Execute
        .i_pipe_TargetAddr(w_execute_TargetAddr),
        .i_pipe_AluResult( w_execute_AluResult),
        .i_pipe_Zero     ( w_execute_Zero),
        .i_pipe_MemToReg ( w_execute_MemToReg),
        .i_pipe_RegWrEn  ( w_execute_RegWrEn),
        .i_pipe_MemWrEn  ( w_execute_MemWrEn),
        .i_pipe_Branch   ( w_execute_Branch),
        .i_pipe_Jump     ( w_execute_Jump),
        .i_pipe_Reg2Data ( w_execute_Reg2Data),
        .i_pipe_RegDst   ( w_execute_RegDst),

        // Outputs for Writeback
        .o_pipe_MemData  ( w_mem_MemData),
        .o_pipe_AluResult( w_mem_AluResult),
        .o_pipe_RegDst   ( w_mem_RegDst),
        .o_pipe_MemToReg ( w_mem_MemToReg),
        .o_pipe_RegWrEn  ( w_mem_RegWrEn)
    );

    // =========================================================================
    // Writeback Stage
    // =========================================================================
    writeback u_writeback (
        .clk             (clk),
        .reset           (reset),

        // Signals passed along memory stage
        .i_pipe_MemData  (w_mem_MemData),
        .i_pipe_MemToReg (w_mem_MemToReg),
        .i_pipe_RegWrEn  (w_mem_RegWrEn),
        .i_pipe_AluResult(w_mem_AluResult),
        .i_pipe_RegDst   (w_mem_RegDst),

        // Outputs to register file (Decode)
        .o_RegDst        (w_wb_RegDst),
        .o_RegWrData     (w_wb_RegWrData),
        .o_RegWrEn       (w_wb_RegWrEn)
    );

endmodule