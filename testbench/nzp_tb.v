`timescale 1ns/1ps

module nzp_tb;
    reg clk;
    reg reset;
    reg we;
    reg N_in, Z_in, P_in;
    wire N, Z, P;

    nzp_reg uut (
        .clk(clk),
        .reset(reset),
        .we(we),
        .N_in(N_in), .Z_in(Z_in), .P_in(P_in),
        .N(N), .Z(Z), .P(P)
    );

    // 10 ns clock period
    always #5 clk = ~clk;

    initial begin
        $dumpfile("sim/nzp_test.vcd");
        $dumpvars(0, nzp_tb);

        // init
        clk   = 0;
        reset = 1;
        we    = 0;
        N_in  = 0; Z_in = 0; P_in = 0;

        // hold reset for one edge
        #12;
        reset = 0;

        // 1) write N=1,Z=0,P=0
        we   = 1;
        N_in = 1; Z_in = 0; P_in = 0;
        #10;   // one clock

        // 2) change inputs but we=0 → outputs should stay same
        we   = 0;
        N_in = 0; Z_in = 1; P_in = 0;
        #10;

        // 3) write Z=1
        we   = 1;
        N_in = 0; Z_in = 1; P_in = 0;
        #10;

        // 4) write P=1
        N_in = 0; Z_in = 0; P_in = 1;
        #10;

        // 5) assert reset again → N=0,Z=1,P=0
        reset = 1;
        #10;

        $finish;
    end
endmodule
