`include "defines.vh"

module instruction_memory (
    input  [15:0] addr,          // Address from PC (word address)
    output [15:0] instruction
);
    reg [15:0] mem [0:511];      // 512 words = 1 KiB memory

    initial begin
        mem[0]  = 16'b0111_001_0_00000000;   // LUI R1,0
        mem[1]  = 16'b0101_001_0_00000101;   // ADDI R1,R1,5

        mem[2]  = 16'b0101_010_0_00000011;   // ADDI R2,R0,3
        mem[3]  = 16'b0000_011_001_010_000;  // ADD  R3,R1,R2

        mem[4]  = 16'b0100_000_001_010_000;  // CMP R1,R2
        mem[5]  = 16'b1011_111111111110;     // BLT -2

        mem[6]  = 16'b1101_000000001010;     // CALL 10
        mem[7]  = 16'b1100_000000001100;     // JMP  12

        mem[10] = 16'b0000_100_001_001_000;  // func start here: ADD R4,R1,R1
        mem[11] = 16'b1110_000000000000;     // RET

        mem[12] = 16'b1111_000000000000;     // HALT
    end


    assign instruction = mem[addr[8:0]]; // use lower 9 bits (512 words)
endmodule
