//=============================================
// Global Definitions for 16-bit ISA CPU
//=============================================
`define WORD_WIDTH 16
`define REG_COUNT  8

// R-type
`define OPC_ADD   4'b0000
`define OPC_SUB   4'b0001
`define OPC_AND   4'b0010
`define OPC_OR    4'b0011
`define OPC_CMP   4'b0100

// Immediate-type
`define OPC_ADDI  4'b0101
`define OPC_ORI   4'b0110
`define OPC_LUI   4'b0111

// Memory
`define OPC_LD    4'b1000
`define OPC_ST    4'b1001

// Branch
`define OPC_BEQ   4'b1010
`define OPC_BLT   4'b1011

// Jump / Call / Ret / Halt
`define OPC_JMP   4'b1100
`define OPC_CALL  4'b1101
`define OPC_RET   4'b1110
`define OPC_HALT  4'b1111
