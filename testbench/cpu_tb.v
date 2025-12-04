`timescale 1ns/1ps
module cpu_tb;
    reg clk;
    reg [15:0] a, b;
    reg [3:0] alu_op;
    wire [15:0] result;
    wire N, Z, P;

    alu uut(.a(a), .b(b), .alu_op(alu_op), .result(result), .N(N), .Z(Z), .P(P));

    initial begin
        $dumpfile("sim/alu_test.vcd");
        $dumpvars(0, cpu_tb);

        a = 16'd10; b = 16'd5; alu_op = 4'b0000; #10;  // ADD
        a = 16'd10; b = 16'd5; alu_op = 4'b0001; #10;  // SUB
        a = 16'hF0F0; b = 16'h0FF0; alu_op = 4'b0010; #10;  // AND
        a = 16'hF0F0; b = 16'h0FF0; alu_op = 4'b0011; #10;  // OR
        a = 16'd5; b = 16'd5; alu_op = 4'b0100; #10;  // CMP
        $finish;
    end
endmodule
