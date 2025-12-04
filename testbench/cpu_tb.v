`timescale 1ns/1ps

module cpu_tb;
    reg clk;
    reg reset;

    // Instantiate CPU
    cpu_top uut (
        .clk(clk),
        .reset(reset)
    );

    // Clock generation
    always #5 clk = ~clk;   // 100 MHz clock (10ns period)

    initial begin
        $dumpfile("sim/cpu_test.vcd");
        $dumpvars(0, cpu_tb);

        clk = 0;
        reset = 1;

        #20;
        reset = 0;

        // Run for a while until HALT is fetched
        #500;

        $display("CPU simulation complete.");
        $finish;
    end
endmodule
