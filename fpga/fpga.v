module fpga (
    input  [9:0] SW,        // switches
    output [9:0] LEDR       // LEDs
);
    // 4-bit operands
    wire [3:0] A = SW[9:6];
    wire [3:0] B = SW[5:2];

    // ALU operation (2 bits mapped to 4-bit ALUOp)
    wire [3:0] alu_op;
    assign alu_op =
        (SW[1:0] == 2'b00) ? 4'b0000 :    // ADD
        (SW[1:0] == 2'b01) ? 4'b0001 :    // SUB
        (SW[1:0] == 2'b10) ? 4'b0010 :    // AND
                            4'b0011;     // OR
    // ALU wires
    wire [15:0] result;
    wire N, Z, P;
    alu alu_inst (
        .a({12'b0, A}),    // extend to 16 bits
        .b({12'b0, B}),
        .alu_op(alu_op),
        .result(result),
        .N(N), .Z(Z), .P(P)
    );
    // LEDs
    assign LEDR[3:0] = result[3:0];  // show 4-bit result
    assign LEDR[7]   = P;
    assign LEDR[8]   = Z;
    assign LEDR[9]   = N;
    // unused LEDs: LEDR[6:4]
endmodule