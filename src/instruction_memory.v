`include "defines.vh"

module instruction_memory (
    input  [15:0] addr,          // Address from PC (word address)
    output [15:0] instruction
);
    reg [15:0] mem [0:511];      // 512 words = 1 KiB memory

    initial begin
        // Example machine code program for testing
        mem[0] = 16'b0000_001_010_011_000; // ADD R1,R2,R3
        mem[1] = 16'b0101_100_000_000101; // ADDI R4,R0,5
        mem[2] = 16'b1111_0000_0000_0000; // HALT
    end

    assign instruction = mem[addr[8:0]]; // use lower 9 bits (512 words)
endmodule
