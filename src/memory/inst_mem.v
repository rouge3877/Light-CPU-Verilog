`include "light_rv32i_defs.vh"

module inst_mem #(
    parameter MEM_INIT_FILE     = "inst_mem_init.hex",
    parameter MEM_ADDR_WIDTH    = `_MEM_ADDR_WIDTH_,
    parameter INST_WIDTH        = `_INST_WIDTH_,
    parameter INST_MEM_WIDTH        = `_INST_WIDTH_ >> 2,
    parameter INST_MEM_SIZE     = `_INST_MEM_SIZE_
) (
    input wire clk,
    input wire reset,
    input wire [MEM_ADDR_WIDTH-1:0] i_Addr,
    output reg [INST_WIDTH-1:0] o_Data
);

    // 定义指令存储器
    reg [INST_MEM_WIDTH-1:0] mem [0:INST_MEM_SIZE-1];
    
    integer i;

    // 初始化指令存储器（仅在仿真中有效）
    initial begin
        $readmemh(MEM_INIT_FILE, mem);
        $display("Instruction memory initialized from file: %s", MEM_INIT_FILE);
    end

    // 读逻辑和写逻辑
    always @(posedge clk or posedge reset) begin
        if (reset) begin
            $readmemh(MEM_INIT_FILE, mem);    
        end else begin
            // mem is byte addressed, endianness is little
            // o_Data = {mem[i_Addr+3], mem[i_Addr+2], mem[i_Addr+1], mem[i_Addr+0]};
        end
    end
    always @(*) begin
        o_Data = {mem[i_Addr+3], mem[i_Addr+2], mem[i_Addr+1], mem[i_Addr+0]};
    end


endmodule
