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

    input  [31:0] reg1_rdata_i, // register read data
    input  [31:0] reg2_rdata_i, // register read data

    output reg [11:0] imme_o,    // immediate data
    output reg [ 4:0] rd_o,      // destination register
    output reg [ 4:0] rs1_o,     // source register 1
    output reg [ 4:0] rs2_o,     // source register 2
    output reg [ 2:0] funct3_o,  // operation code
    output reg [ 6:0] funct7_o,  // operation code
    output reg [ 6:0] opcode_o,  // operation code

    output reg [31:0] reg1_rdata_o, // register read data
    output reg [31:0] reg2_rdata_o // register read data
);

  //
  wire [6:0] opcode = instr_i[6:0];   // opreation code
  wire [2:0] funct3 = instr_i[14:12]; // operation code
  wire [6:0] funct7 = instr_i[31:25]; // operation code
  wire [4:0] rd  = instr_i[11:7]; // destination register
  wire [4:0] rs1 = instr_i[19:15]; // source register 1
  wire [4:0] rs2 = instr_i[24:20]; // source register 2
  wire [31:0] imme_i = { {20{instr_i[31]}}, instr_i[31:20]};  // i type immediate data
  wire [31:0] imme_s = { {20{instr_i[31]}}, instr_i[31:25],  instr_i[11:7]}; // s type immediate data
  wire [31:0] imme_b = { {20{instr_i[31]}}, instr_i[31], instr_i[7], instr_i[30:25], instr_i[11:8], 1'b0}; // b type immediate data
  wire [31:0] imme_j = { {20{instr_i[31]}}, instr_i[31], instr_i[19:12], instr_i[20], instr_i[30:21], 1'b0}; // j type immediate data
  wire [31:0] imme_u = { instr_i[31:12], 12'b0}; // lui type immediate data

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
    rs1_o <= rs1;
    rs2_o <= rs2;
    funct3_o <= funct3;
    funct7_o <= funct7;
    opcode_o <= opcode;
    
    // register read data
    reg1_rdata_o <= reg1_rdata_i;
    reg2_rdata_o <= reg2_rdata_i;
  end

endmodule