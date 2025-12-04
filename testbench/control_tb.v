`timescale 1ns/1ps

module control_tb;

    reg  [15:0] instr;
    wire RegWrite, ALUSrc, MemWrite, MemToReg, NZP_we;
    wire [1:0] WBSelect, BranchCond;
    wire Branch, Jump, Call, Ret, Halt;
    wire [3:0] ALUOp;

    control_unit uut (
        .instr(instr),
        .RegWrite(RegWrite),
        .ALUSrc(ALUSrc),
        .MemWrite(MemWrite),
        .MemToReg(MemToReg),
        .WBSelect(WBSelect),
        .NZP_we(NZP_we),
        .Branch(Branch),
        .BranchCond(BranchCond),
        .Jump(Jump),
        .Call(Call),
        .Ret(Ret),
        .Halt(Halt),
        .ALUOp(ALUOp)
    );

    task show;
        begin
            $display("INSTR = %h", instr);
            $display("RegWrite=%b ALUSrc=%b MemWrite=%b MemToReg=%b WBSelect=%b",
                     RegWrite, ALUSrc, MemWrite, MemToReg, WBSelect);
            $display("NZP_we=%b Branch=%b BranchCond=%b Jump=%b Call=%b Ret=%b Halt=%b",
                     NZP_we, Branch, BranchCond, Jump, Call, Ret, Halt);
            $display("ALUOp=%b\n", ALUOp);
        end
    endtask

    initial begin
        $dumpfile("sim/control_test.vcd");
        $dumpvars(0, control_tb);

        // =====================
        // R-TYPE tests
        // =====================
        instr = 16'h0000; #1; show;   // ADD
        instr = 16'h1000; #1; show;   // SUB
        instr = 16'h2000; #1; show;   // AND
        instr = 16'h3000; #1; show;   // OR
        instr = 16'h4000; #1; show;   // CMP

        // =====================
        // Immediate tests
        // =====================
        instr = 16'h5000; #1; show;   // ADDI
        instr = 16'h6000; #1; show;   // ORI
        instr = 16'h7000; #1; show;   // LUI

        // =====================
        // LD / ST tests
        // =====================
        instr = 16'h8000; #1; show;   // LD
        instr = 16'h9000; #1; show;   // ST

        // =====================
        // Branch tests
        // =====================
        instr = 16'hA000; #1; show;   // BEQ
        instr = 16'hB000; #1; show;   // BLT

        // =====================
        // Jumps
        // =====================
        instr = 16'hC000; #1; show;   // JMP
        instr = 16'hD000; #1; show;   // CALL
        instr = 16'hE000; #1; show;   // RET
        instr = 16'hF000; #1; show;   // HALT

        $finish;
    end
endmodule
