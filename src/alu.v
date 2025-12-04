`include "defines.vh"

module alu (
    input  [15:0] a,
    input  [15:0] b,
    input  [3:0]  alu_op,
    output reg [15:0] result,
    output reg N, Z, P
);
    always @(*) begin
        case (alu_op)
            4'b0000: result = a + b;   // ADD
            4'b0001: result = a - b;   // SUB
            4'b0010: result = a & b;   // AND
            4'b0011: result = a | b;   // OR
            4'b0100: result = a - b;   // CMP
            default: result = 16'h0000;
        endcase

        // NZP flag logic
        N = result[15];
        Z = (result == 0);
        P = (~N & ~Z);
    end
endmodule
