`include "defines.vh"

module cpu_top (
    input clk,
    input reset
);
    // ------------------------------------------------------------
    // Program Counter + Instruction Fetch
    // ------------------------------------------------------------
    wire [15:0] pc_out;
    wire [15:0] pc_next;
    wire [15:0] pc_plus_1;

    assign pc_plus_1 = pc_out + 16'd1;

    // PC write is disabled only on HALT
    wire pc_write;

    program_counter pc (
        .clk(clk),
        .reset(reset),
        .pc_write(pc_write),
        .pc_next(pc_next),
        .pc_out(pc_out)
    );

    // Instruction memory (word address)
    wire [15:0] instr;

    instruction_memory imem (
        .addr(pc_out),
        .instruction(instr)
    );

    // Common fields
    wire [3:0] opcode = instr[15:12];

    // ------------------------------------------------------------
    // Control Unit
    // ------------------------------------------------------------
    wire RegWrite;
    wire ALUSrc;
    wire MemWrite;
    wire MemToReg;
    wire [1:0] WBSelect;     // 00=ALU, 01=MEM, 10=LUI
    wire NZP_we;
    wire Branch;
    wire [1:0] BranchCond;   // 00=EQ, 01=LT
    wire Jump;
    wire Call;
    wire Ret;
    wire Halt;
    wire [3:0] ALUOp;

    control_unit cu (
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

    assign pc_write = ~Halt;

    // ------------------------------------------------------------
    // Register File
    // ------------------------------------------------------------
    localparam [2:0] LR_REG = 3'b111;   // Link register used by CALL / RET

    wire [2:0] rs1_addr, rs2_addr, rd_addr;
    wire [15:0] reg_read1, reg_read2;
    wire [15:0] reg_write_data;
    wire        reg_we;

    // Helper opcode flags
    wire is_addi = (opcode == `OPC_ADDI);
    wire is_ori  = (opcode == `OPC_ORI);
    wire is_lui  = (opcode == `OPC_LUI);
    wire is_ld   = (opcode == `OPC_LD);
    wire is_st   = (opcode == `OPC_ST);

    // rs1: ALU A operand, base register for LD/ST, LR for RET
    assign rs1_addr =
        Ret              ? LR_REG      : // RET reads LR
        (is_ld || is_st) ? instr[8:6]  : // base register
        (is_addi || is_ori) ? instr[11:9] : // rd is also source
                              instr[8:6];   // R-type, CMP, etc.

    // rs2: second ALU source (R-type) or store data for ST
    assign rs2_addr =
        is_st ? instr[11:9] :   // ST uses ra as store source
        (opcode == `OPC_ADD  ||
         opcode == `OPC_SUB  ||
         opcode == `OPC_AND  ||
         opcode == `OPC_OR   ||
         opcode == `OPC_CMP) ? instr[5:3] :
         3'b000; // otherwise unused

    // Destination register (rd)
    assign rd_addr =
        (opcode == `OPC_ADD  ||
         opcode == `OPC_SUB  ||
         opcode == `OPC_AND  ||
         opcode == `OPC_OR   ||
         opcode == `OPC_ADDI ||
         opcode == `OPC_ORI  ||
         opcode == `OPC_LUI  ||
         opcode == `OPC_LD)  ? instr[11:9] :
        Call ? LR_REG :     // CALL writes PC+1 to LR
        3'b000;

    // RegWrite is OR'ed with Call so CALL can write LR
    assign reg_we = RegWrite | Call;

    reg_file rf (
        .clk(clk),
        .we(reg_we),
        .rs1(rs1_addr),
        .rs2(rs2_addr),
        .rd(rd_addr),
        .write_data(reg_write_data),
        .read_data1(reg_read1),
        .read_data2(reg_read2)
    );

    // Value of LR (for RET) is just reg_read1 when Ret=1
    wire [15:0] lr_value = reg_read1;

    // ------------------------------------------------------------
    // Immediate Generation
    // ------------------------------------------------------------
    // imm6 for LD/ST (signed)
    wire [15:0] imm6_sext = {{10{instr[5]}}, instr[5:0]};

    // imm8 for ADDI/ORI/LUI
    wire [15:0] imm8_sext = {{8{instr[7]}}, instr[7:0]};   // signed
    wire [15:0] imm8_zext = {8'b0, instr[7:0]};           // zero-extended

    // Branch offset (signed 12 bits)
    wire [15:0] branch_offset = {{4{instr[11]}}, instr[11:0]};

    // Jump target from instruction (absolute, 0..4095)
    wire [15:0] jump_target_imm = {4'b0000, instr[11:0]};

    // LUI value: imm8 placed in upper byte
    wire [15:0] lui_value = {instr[7:0], 8'b0};

    // Immediate used by ALU when ALUSrc=1
    wire [15:0] alu_immediate =
        is_addi       ? imm8_sext :
        is_ori        ? imm8_zext :
        (is_ld || is_st) ? imm6_sext :
        16'h0000;

    // ------------------------------------------------------------
    // ALU + NZP flags
    // ------------------------------------------------------------
    wire [15:0] alu_b = ALUSrc ? alu_immediate : reg_read2;
    wire [15:0] alu_result;
    wire alu_N, alu_Z, alu_P;

    alu alu_core (
        .a(reg_read1),
        .b(alu_b),
        .alu_op(ALUOp),
        .result(alu_result),
        .N(alu_N),
        .Z(alu_Z),
        .P(alu_P)
    );

    // NZP register (holds flags across instructions)
    wire N, Z, P;

    nzp_reg nzp (
        .clk(clk),
        .reset(reset),
        .we(NZP_we),
        .N_in(alu_N),
        .Z_in(alu_Z),
        .P_in(alu_P),
        .N(N),
        .Z(Z),
        .P(P)
    );

    // ------------------------------------------------------------
    // Data Memory
    // ------------------------------------------------------------
    wire [15:0] data_rdata;
    wire [15:0] data_wdata = reg_read2;  // ST stores rs2

    data_memory dmem (
        .clk(clk),
        .we(MemWrite),
        .addr(alu_result),   // base + offset from ALU
        .wdata(data_wdata),
        .rdata(data_rdata)
    );

    // ------------------------------------------------------------
    // Write-back Mux (ALU / MEM / LUI / CALL)
    // ------------------------------------------------------------
    wire [15:0] wb_core =
        (WBSelect == 2'b10) ? lui_value :      // LUI
        (MemToReg)          ? data_rdata :     // LD
                              alu_result;      // ALU result

    // CALL overrides and writes PC+1 into LR
    assign reg_write_data = Call ? pc_plus_1 : wb_core;

    // ------------------------------------------------------------
    // Branch / Jump / PC selection
    // ------------------------------------------------------------
    // branch target: PC+1 + signed offset
    wire [15:0] branch_target = pc_plus_1 + branch_offset;

    // jump target: either absolute imm12 or LR for RET
    wire [15:0] jump_target = Ret ? lr_value : jump_target_imm;

    // branch condition evaluation
    wire cond_eq = (BranchCond == 2'b00) && Z;
    wire cond_lt = (BranchCond == 2'b01) && N;
    wire branch_taken = Branch && (cond_eq || cond_lt);

    wire jump_taken = Jump | Call | Ret;

    wire [1:0] pc_sel =
        jump_taken   ? 2'b10 :
        branch_taken ? 2'b01 :
                       2'b00;

    assign pc_next =
        (pc_sel == 2'b00) ? pc_plus_1   :
        (pc_sel == 2'b01) ? branch_target :
                            jump_target;

endmodule
