`include "light_rv32i_defs.vh"

module access_mem(
    input  clk,
    input  reset,

    output wire o_ctl_NextPC,

    // --- pipeline ---
    // former result
    input wire [31:0] i_pipe_TargetAddr,
    input wire [31:0] i_pipe_AluResult,
    input wire        i_pipe_Zero,

    // control signals
    input wire        i_pipe_MemToReg,
    input wire        i_pipe_RegWrEn,
    input wire        i_pipe_MemWrEn,
    input wire        i_pipe_Branch,
    input wire        i_pipe_Jump,

    // pass through
    input wire [31:0] i_pipe_Reg2Data,
    input wire [4:0]  i_pipe_RegDst,

    // this result
    output reg [31:0] o_pipe_MemData,

    // pass through
    output reg [31:0] o_pipe_AluResult,
    output reg [4:0]  o_pipe_RegDst,

    // control signals
    output reg       o_pipe_MemToReg,
    output reg       o_pipe_RegWrEn
);

    // Instantiate data memory
    wire [31:0] w_MemData;

    data_mem #(
        .MEM_INIT_FILE("data_mem_init.hex")
    ) data_memory (
        .clk(clk),
        .reset(reset),
        .i_Addr(i_pipe_AluResult),
        .i_DataIn(i_pipe_Reg2Data),
        .i_WrEn(i_pipe_MemWrEn),
        .o_DataOut(w_MemData)
    );

    // Beq: Write PC logic
    assign o_ctl_NextPC = i_pipe_Jump || (i_pipe_Branch && i_pipe_Zero);


    always @(posedge clk or posedge reset) begin
        if (reset) begin
            o_pipe_MemData <= 0;

            o_pipe_AluResult <= 0;
            o_pipe_RegDst <= 0;
            o_pipe_MemToReg <= 0;
            o_pipe_RegWrEn <= 0;
        end else begin
            o_pipe_MemData <= w_MemData;

            o_pipe_AluResult <= i_pipe_AluResult;
            o_pipe_RegDst <= i_pipe_RegDst;
            o_pipe_MemToReg <= i_pipe_MemToReg;
            o_pipe_RegWrEn <= i_pipe_RegWrEn;
        end
    end

endmodule