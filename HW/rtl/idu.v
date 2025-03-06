//============================================================
//
// ifu.v
// instruction fetch unit
// - fetches instructions from SRAM
// 
//============================================================

`include "define.v"
module idu (
    input  clk,
    input  rst_n,
    
    input  [31:0] instr_i, // instruction, from ifu

    input  jump_hold_i, // from exu
    input  ls_hold_i, // from exu

    input  [31:0] reg1_rdata_i, // register read data, from regfile
    input  [31:0] reg2_rdata_i, // register read data, from regfile

    output  [ 4:0] rs1_o,     // source register 1, to regfile
    output  [ 4:0] rs2_o,     // source register 2, to regfile

    output reg [11:0] imme_o,    // immediate data
    output reg [ 4:0] rd_o,      // destination register
    output reg [ 2:0] funct3_o,  // operation code
    output reg [ 6:0] funct7_o,  // operation code
    output reg [ 6:0] opcode_o,  // operation code

    output reg [31:0] reg1_rdata_o, // register read data
    output reg [31:0] reg2_rdata_o // register read data
);

  wire [31:0] instr_tmp = jump_hold_i | ls_hold_i ? `NOP : instr_i; // jump or hold will generate nop instruction

  assign rs1_o = instr_tmp[19:15]; // source register 1
  assign rs2_o = instr_tmp[24:20]; // source register 2

  //
  wire [6:0] opcode = instr_tmp[6:0];   // opreation code
  wire [2:0] funct3 = instr_tmp[14:12]; // operation code
  wire [6:0] funct7 = instr_tmp[31:25]; // operation code
  wire [4:0] rd  = instr_tmp[11:7]; // destination register

  wire [31:0] imme_i = { {20{instr_tmp[31]}}, instr_tmp[31:20]};  // i type immediate data
  wire [31:0] imme_s = { {20{instr_tmp[31]}}, instr_tmp[31:25],  instr_tmp[11:7]}; // s type immediate data
  wire [31:0] imme_b = { {20{instr_tmp[31]}}, instr_tmp[31], instr_tmp[7], instr_tmp[30:25], instr_tmp[11:8], 1'b0}; // b type immediate data
  wire [31:0] imme_j = { {20{instr_tmp[31]}}, instr_tmp[31], instr_tmp[19:12], instr_tmp[20], instr_tmp[30:21], 1'b0}; // j type immediate data
  wire [31:0] imme_u = { instr_tmp[31:12], 12'b0}; // lui type immediate data

  wire [31:0] imme_tmp = opcode == `TYPE_I ? imme_i : 
                         opcode == `TYPE_L ? imme_i :
                         opcode == `TYPE_S ? imme_s : 
                         opcode == `TYPE_B ? imme_b : 
                         opcode == `TYPE_JAL ? imme_j : 
                         opcode == `TYPE_JALR ? imme_i : 
                         (opcode == `TYPE_LUI) | (opcode == `TYPE_AUIPC) ? imme_u : 32'b0; // immediate data


  always @(posedge clk ) begin
    // instruction decode
    imme_o <= imme_tmp;
    rd_o <= rd;
    funct3_o <= funct3;
    funct7_o <= funct7;
    opcode_o <= opcode;
    
    // register read data
    reg1_rdata_o <= reg1_rdata_i;
    reg2_rdata_o <= reg2_rdata_i;
  end

endmodule