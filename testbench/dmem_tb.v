`timescale 1ns/1ps

module dmem_tb;

    reg clk;
    reg we;
    reg [15:0] addr, wdata;
    wire [15:0] rdata;

    data_memory uut (
        .clk(clk),
        .we(we),
        .addr(addr),
        .wdata(wdata),
        .rdata(rdata)
    );

    // clock toggles every 5ns → 10ns period
    always #5 clk = ~clk;

    initial begin
        $dumpfile("sim/dmem_test.vcd");
        $dumpvars(0, dmem_tb);

        clk = 0;
        we  = 0;
        addr = 0;
        wdata = 0;

        // -------------------------
        // Test 1: Asynchronous read
        // -------------------------
        addr = 16'd10;
        #5;  // no write yet, value = unknown/0
        // Expect rdata = X or 0000 depending on initialization (not an error)

        // -------------------------
        // Test 2: Write to memory
        // -------------------------
        addr  = 16'd10;
        wdata = 16'hABCD;
        we    = 1;
        #10;  // wait for posedge clk

        // -------------------------
        // Test 3: Read back (async)
        // -------------------------
        we = 0;
        addr = 16'd10;
        #5;
        // Expect rdata = ABCD

        // -------------------------
        // Test 4: Address masking test
        // Write to address 0x1FF (511)
        // -------------------------
        addr = 16'd511;
        wdata = 16'h1234;
        we = 1;
        #10;

        // Read from same address
        we = 0;
        addr = 16'd511;
        #5;
        // Expect rdata = 1234

        // -------------------------
        // Test 5: Check 9-bit addressing (addr wraps)
        // addr 0x03FF → masked to 9 bits → 0x1FF
        // -------------------------
        addr = 16'h03FF;   // binary: 0000_0011_1111_1111
        #5;
        // Expect rdata = 1234 (same as address 511)

        // -------------------------
        // Test 6: Another write at address 0
        // -------------------------
        addr  = 16'd0;
        wdata = 16'hDEAD;
        we    = 1;
        #10;

        // Async read
        we = 0;
        addr = 16'd0;
        #5;                 // Expect DEAD

        $finish;
    end
endmodule
