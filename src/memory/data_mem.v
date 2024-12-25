`include "light_rv32i_defs.vh"

module data_mem #(
    parameter MEM_INIT_FILE = "data_mem_init.hex",
    parameter MEM_ADDR_WIDTH = `_MEM_ADDR_WIDTH_,
    parameter DATA_WIDTH = `_DATA_WIDTH_,
    parameter DATA_MEM_SIZE = `_DATA_MEM_SIZE_
) (
    input wire clk,
    input wire reset,
    input wire [MEM_ADDR_WIDTH-1:0] i_Addr,
    input wire [DATA_WIDTH-1:0] i_DataIn,
    input wire i_WrEn,
    output reg [DATA_WIDTH-1:0] o_DataOut
);

    // 定义数据存储器
    reg [DATA_WIDTH-1:0] r_mem [0:DATA_MEM_SIZE-1];
    
    integer i;
    
    initial begin
        // 初始化数据存储器
        if (!$readmemh(MEM_INIT_FILE, r_mem)) begin
            $display("Error: Failed to initialize data memory from file %s", MEM_INIT_FILE);
        end else begin
            for (i = 0; i < DATA_MEM_SIZE; i = i + 1) begin
                r_mem[i] = {DATA_WIDTH{1'b0}};
            end
        end
    end

    // 读逻辑：组合逻辑实现
    always @(*) begin
        o_DataOut = r_mem[i_Addr];
    end

    // 写逻辑：时序逻辑
    always @(posedge clk or posedge reset) begin
        if (reset) begin
            for (i = 0; i < DATA_MEM_SIZE; i = i + 1) begin
                r_mem[i] <= {DATA_WIDTH{1'b0}};
            end
            // 重置时重新初始化文件
            if (!$readmemh(MEM_INIT_FILE, r_mem)) begin
                $display("Error: Failed to initialize data memory from file %s", MEM_INIT_FILE);
            end
        end else if (i_WrEn) begin
            r_mem[i_Addr] <= i_DataIn;
            // 写入文件
            if (!$writememh(MEM_INIT_FILE, r_mem)) begin
                $display("Error: Failed to write data memory to file %s", MEM_INIT_FILE);
            end
        end
    end

endmodule