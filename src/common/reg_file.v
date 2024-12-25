`include "light_rv32i_defs.vh"

module reg_file #(
    parameter ADDR_WIDTH = _REG_ADDR_WIDTH_ ,
    parameter DATA_WIDTH = _REG_DATA_WIDTH_ ,
    parameter REG_NUMBER = _REG_NUMBER_
) (
    input                       clk         ,
    input                       reset       ,

    input   [ADDR_WIDTH-1 : 0]  i_Reg1Addr,
    input   [ADDR_WIDTH-1 : 0]  i_Reg2Addr,

    output wire [DATA_WIDTH-1 : 0]  o_Reg1Data,
    output wire [DATA_WIDTH-1 : 0]  o_Reg2Data,

    input   [ADDR_WIDTH-1 : 0]  i_RegWrAddr  ,
    input   [DATA_WIDTH-1 : 0]  i_RegWrData  ,
    input                       i_RegWrEn
);
    // x0 register is always zero
    // if a register is read and written in the same cycle, 
    //      the read data is the written data

    reg [DATA_WIDTH-1:0] reg_array [0:REG_NUMBER-1];

    // Read ports
    assign o_Reg1Data = (i_Reg1Addr == 0)
        ? 0
        : ((i_RegWrEn && i_RegWrAddr == i_Reg1Addr)
            ? i_RegWrData
            : reg_array[i_Reg1Addr]);

    assign o_Reg2Data = (i_Reg2Addr == 0)
        ? 0
        : ((i_RegWrEn && i_RegWrAddr == i_Reg2Addr)
            ? i_RegWrData
            : reg_array[i_Reg2Addr]);

    // Write port
    integer i;
    always @(posedge clk or posedge reset) begin
        if (reset) begin
            for (i = 0; i < REG_NUMBER; i = i + 1) begin
                reg_array[i] <= 0;
            end
        end else if (i_RegWrEn && i_RegWrAddr != 0) begin
            reg_array[i_RegWrAddr] <= i_RegWrData;
        end
    end
endmodule
