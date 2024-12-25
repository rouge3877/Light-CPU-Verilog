`include "light_rv32i_defs.vh"

module data_mem #(
    parameter MEM_INIT_FILE = "data_mem_init.hex",
    parameter MEM_ADDR_WIDTH = `_MEM_ADDR_WIDTH_,
    parameter DATA_WIDTH = `_MEM_DATA_WIDTH_,
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
        $readmemh(MEM_INIT_FILE, r_mem);
        // 可选：显示初始化完成信息
        $display("Data memory initialized from file: %s", MEM_INIT_FILE);
    end

    // 读逻辑：组合逻辑实现
    always @(*) begin
        o_DataOut = r_mem[i_Addr];
    end

    // 写逻辑：时序逻辑
    always @(posedge clk or posedge reset) begin
        if (reset) begin
            // 重置所有内存单元为零
            for (i = 0; i < DATA_MEM_SIZE; i = i + 1) begin
                r_mem[i] <= {DATA_WIDTH{1'b0}};
            end
            $readmemh(MEM_INIT_FILE, r_mem);
            $display("Data memory re-initialized from file: %s", MEM_INIT_FILE);
        end 
        else if (i_WrEn) begin
            r_mem[i_Addr] <= i_DataIn;
            // 写入文件（仅用于仿真，不建议用于合成）
            $writememh(MEM_INIT_FILE, r_mem);
            // 可选：显示写入完成信息
            $display("Data memory written to file: %s", MEM_INIT_FILE);
        end
    end

endmodule
