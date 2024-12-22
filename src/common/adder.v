`include "light_rv32i_defs.vh"

module adder #(
    parameter N = `_REG_DATA_WIDTH_
) (
    input  [N-1:0] i_a,
    input  [N-1:0] i_b,
    input          i_c,
    output wire [N-1:0] o_s,
    output wire         o_c
);
    wire [N-1:0] G;  // 生成信号
    wire [N-1:0] P;  // 传递信号
    wire [N:0]   C;  // 进位信号

    assign C[0] = i_c;

    genvar i;
    generate
        for (i = 0; i < N; i = i + 1) begin : cla_logic
            assign G[i] = i_a[i] & i_b[i];
            assign P[i] = i_a[i] ^ i_b[i];
            assign C[i+1] = G[i] | (P[i] & C[i]);
            assign o_s[i] = P[i] ^ C[i];
        end
    endgenerate

    assign o_c = C[N];
endmodule