//======================================================
//
//  IFU: Instruction Fetch Unit
//
//  - Fetches instructions from SRAM
//  - Increments PC
//
//======================================================

`include "define.v"

module ifu (
    input  clk,
    input  rst_n,

    input         instr_valid_i, // from instr_rom
    input  [31:0] instr_i,       // from instr_rom

    input  [31:0] pc_next_i,    // from exu, jump pc
    input         jump_valid_i, // from exu, jump 
    input         hold_valid_i, // from exu, hold

    output reg [31:0] pc_o, // pc, to sram
    output reg [31:0] pc_d_o,
    output reg [31:0] instr_o
);
/*
 *                     ____
 * instr_valid_i: ____|    |____
 *                     ____
 * instr_i:       ____|    |____     
 *                         ____
 * instr_o:           ____|    |____     
 */

  always @(posedge clk or negedge rst_n) begin
    if (~rst_n) begin
      pc_o <= 32'b0;
    end 
    else if(jump_valid_i) begin
      pc_o <= pc_next_i; // jump instruction
    end
    else if(hold_valid_i) begin
      pc_o <= pc_o; // hold instruction
    end
    else begin
      pc_o <= pc_o + 'd4; // 32bit bus
    end
  end
 
  // PIPELINE
  always @(posedge clk ) begin
    if(hold_valid_i)begin
      instr_o <= instr_o; // instruction
      pc_d_o <= pc_d_o;
    end
    else begin
      instr_o <= instr_i; // instruction
      pc_d_o <= pc_o;
    end
  end

endmodule
