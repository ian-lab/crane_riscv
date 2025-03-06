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

    input         instr_valid_i, // from sram
    input  [31:0] instr_i, // from sram

    input  [31:0] pc_next_i, // from exu
    input         jump_valid_i, // from exu
    input         hold_valid_i, // from exu

    output reg [31:0] pc_o, // pc, to sram

    output reg [31:0] instr_valid_o // to exu
);
/*
 *                     ____
 * instr_valid_i: ____|    |____
 *                     ____
 * instr_i:       ____|    |____     
 *                         ____
 * instr_valid_o:     ____|    |____
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

  always @(posedge clk or negedge rst_n) begin
    if (~rst_n) begin
      instr_valid_o <= 1'b0;
    end 
    else if (instr_valid_i) begin
      instr_valid_o <= instr_valid_i; // valid instruction
    end
    else begin
      instr_valid_o <= `NOP; // nop inrstuction
    end
  end


endmodule