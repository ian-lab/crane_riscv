//=====================================================================
// COMMON DEFINITION
//
//=====================================================================


`ifndef DEFINE_V
`define DEFINE_V

// INSTRUCTION
`define NOP  32'h0000_006f // nop jal x0,0

// OPCODE
`define TYPE_R     7'b0110011
`define TYPE_I     7'b0010011  
`define TYPE_L     7'b0000011  
`define TYPE_S     7'b0100011
`define TYPE_B     7'b1100011
`define TYPE_JAL   7'b1101111
`define TYPE_JALR  7'b1100111
`define TYPE_LUI   7'b0110111
`define TYPE_AUIPC 7'b0010111

// FUNCT3
// R-type I-type
`define ADD  3'b000
`define SLL  3'b001
`define SLT  3'b010
`define SLTU 3'b011
`define XOR  3'b100
`define SRL  3'b101
`define SRA  3'b101
`define OR   3'b110
`define AND  3'b111
`define SUB  3'b000

`define SLLI 3'b001
`define SRLI  3'b101
`define SRAI  3'b101

// L-type
`define LB   3'b000
`define LH   3'b001
`define LW   3'b010
`define LBU  3'b100
`define LHU  3'b101

// S-type
`define SB   3'b000
`define SH   3'b001
`define SW   3'b010

// B-type
`define BEQ  3'b000
`define BNE  3'b001
`define BLT  3'b100
`define BLTU 3'b110
`define BGE  3'b101
`define BGEU 3'b111



`endif
