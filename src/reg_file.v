`include "defines.vh"

module reg_file (
    input clk,
    input we,  // Write enable
    input [2:0] rs1, rs2, rd,
    input [15:0] write_data,
    output [15:0] read_data1, read_data2
);
    reg [15:0] regs[`REG_COUNT-1:0];
    integer i;
    initial begin
        for (i = 0; i < 8; i = i + 1) begin
            regs[i] = 16'd0;
        end
    end

    assign read_data1 = regs[rs1];
    assign read_data2 = regs[rs2];

    always @(posedge clk)
        if (we && rd != 0)
            regs[rd] <= write_data;
endmodule
