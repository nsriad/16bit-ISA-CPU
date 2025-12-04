`timescale 1ns/1ps
module cpu_tb;
    reg clk;
    reg [15:0] a, b;
    reg [3:0] alu_op;
    wire [15:0] result;
    wire N, Z, P;

    alu uut(.a(a), .b(b), .alu_op(alu_op), .result(result), .N(N), .Z(Z), .P(P));

    initial begin
        $dumpfile("sim/alu_test_2.vcd");
        $dumpvars(0, cpu_tb);

        // -------------------------
        // ADD tests
        // -------------------------
        a = 16'd10; b = 16'd5; alu_op = 4'b0000; #10;   // 10 + 5 = 15   → P=1
        a = 16'hFFFF; b = 16'd1; alu_op = 4'b0000; #10; // -1 + 1 = 0    → Z=1
        a = 16'h8000; b = 16'hFFFF; alu_op = 4'b0000; #10; // Negative + -1 = more negative → N=1

        // -------------------------
        // SUB tests
        // -------------------------
        a = 16'd10; b = 16'd5; alu_op = 4'b0001; #10;   // 10 - 5 = 5    → P=1
        a = 16'd5;  b = 16'd5; alu_op = 4'b0001; #10;   // 5 - 5 = 0     → Z=1
        a = 16'd3;  b = 16'd7; alu_op = 4'b0001; #10;   // 3 - 7 = -4    → N=1

        // -------------------------
        // AND tests
        // -------------------------
        a = 16'hF0F0; b = 16'h0FF0; alu_op = 4'b0010; #10; // Result positive
        a = 16'h0000; b = 16'hFFFF; alu_op = 4'b0010; #10; // Zero result → Z=1

        // -------------------------
        // OR tests
        // -------------------------
        a = 16'h8000; b = 16'h0001; alu_op = 4'b0011; #10; // Negative result → N=1
        a = 16'h0000; b = 16'h0000; alu_op = 4'b0011; #10; // Zero result

        // -------------------------
        // CMP tests (result ignored, flags only)
        // -------------------------
        a = 16'd7; b = 16'd7; alu_op = 4'b0100; #10;  // equal → Z=1
        a = 16'd3; b = 16'd8; alu_op = 4'b0100; #10;  // 3<8 → N=1
        a = 16'd9; b = 16'd1; alu_op = 4'b0100; #10;  // 9>1 → P=1

        // -------------------------
        // Edge cases
        // -------------------------
        a = 16'h7FFF; b = 16'd1; alu_op = 4'b0000; #10; // overflow → sign flips → N=1
        a = 16'h8000; b = 16'd1; alu_op = 4'b0001; #10; // most negative - positive → stays negative

        $finish;
    end
endmodule
