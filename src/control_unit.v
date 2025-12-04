`include "defines.vh"

module control_unit (
    input  [15:0] instr,
    output reg RegWrite,
    output reg ALUSrc,
    output reg MemWrite,
    output reg MemToReg,
    output reg [1:0] WBSelect,   // 00=ALU, 01=MEM, 10=LUI
    output reg NZP_we,
    output reg Branch,
    output reg [1:0] BranchCond, // 00=EQ, 01=LT
    output reg Jump,
    output reg Call,
    output reg Ret,
    output reg Halt,
    output reg [3:0] ALUOp
);

    wire [3:0] opcode = instr[15:12];

    always @(*) begin
        // Default all signals to 0
        RegWrite   = 0;
        ALUSrc     = 0;
        MemWrite   = 0;
        MemToReg   = 0;
        WBSelect   = 2'b00;
        NZP_we     = 0;
        Branch     = 0;
        BranchCond = 2'b00;
        Jump       = 0;
        Call       = 0;
        Ret        = 0;
        Halt       = 0;
        ALUOp      = 4'b0000;

        case (opcode)

            // ---------------- R-TYPE ----------------
            `OPC_ADD: begin
                RegWrite = 1;
                ALUOp    = `OPC_ADD;
                NZP_we   = 1;
            end

            `OPC_SUB: begin
                RegWrite = 1;
                ALUOp    = `OPC_SUB;
                NZP_we   = 1;
            end

            `OPC_AND: begin
                RegWrite = 1;
                ALUOp    = `OPC_AND;
                NZP_we   = 1;
            end

            `OPC_OR: begin
                RegWrite = 1;
                ALUOp    = `OPC_OR;
                NZP_we   = 1;
            end

            `OPC_CMP: begin
                ALUOp  = `OPC_CMP;
                NZP_we = 1;       // flags are updated
            end

            // ---------------- Immediate ----------------
            `OPC_ADDI: begin
                RegWrite = 1;
                ALUSrc   = 1;
                ALUOp    = `OPC_ADD;
                NZP_we   = 1;
            end

            `OPC_ORI: begin
                RegWrite = 1;
                ALUSrc   = 1;
                ALUOp    = `OPC_OR;
                NZP_we   = 1;
            end

            `OPC_LUI: begin
                RegWrite = 1;
                WBSelect = 2'b10;   // take LUI value
                // no ALU operation
            end

            // ---------------- Memory ----------------
            `OPC_LD: begin
                RegWrite = 1;
                ALUSrc   = 1;        // base + offset
                ALUOp    = `OPC_ADD;
                MemToReg = 1;        // load from memory
            end

            `OPC_ST: begin
                MemWrite = 1;
                ALUSrc   = 1;
                ALUOp    = `OPC_ADD;
            end

            // ---------------- Branch ----------------
            `OPC_BEQ: begin
                Branch     = 1;
                BranchCond = 2'b00;  // EQ
            end

            `OPC_BLT: begin
                Branch     = 1;
                BranchCond = 2'b01;  // LT (N==1)
            end

            // ---------------- Jump / Call / Return ----------------
            `OPC_JMP: begin
                Jump = 1;
            end

            `OPC_CALL: begin
                Call = 1;
            end

            `OPC_RET: begin
                Ret = 1;
            end

            `OPC_HALT: begin
                Halt = 1;
            end

        endcase
    end
endmodule
