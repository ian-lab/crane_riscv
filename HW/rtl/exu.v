//============================================================
// 
//
//============================================================

`include "define.v"

module exu (
    input clk,
    input rst_n,

    // instruction interface
    input [31:0] pc_i,
    output reg [31:0] pc_next_o,
    output reg jump_flag_o,
    output reg jump_hold_o,
    output reg ls_hold_o,

    input [11:0] imme_i,    // immediate data
    input [ 4:0] rd_i,      // destination register
    input [ 4:0] rs1_i,     // source register 1
    input [ 4:0] rs2_i,     // source register 2
    input [ 2:0] funct3_i,  // operation code
    input [ 6:0] funct7_i,  // operation code
    input [ 6:0] opcode_i,  // operation code

    // register rw interface
    input [31:0] reg1_rdata_i, // register read data
    input [31:0] reg2_rdata_i, // register read data

    output reg reg_wen_o,          // register write enable
    output reg [31:0] reg_waddr_o, // register write address
    output reg [31:0] reg_wdata_o, // register write data
    
    // memory rw interface

    input      [31:0] mem_rdata_i, // memory read data
    output reg [31:0] mem_addr_o,  // memory read address
    output reg [31:0] mem_wdata_o, // memory write data
    output reg [ 1:0] mem_wsize_o, // memory write size
    output reg [ 3:0] mem_wmask_o,   // memory write mask
    output reg mem_sel_o,           // memory select
    output reg mem_wen_o,           // memory write enable
    input mem_ack_i // memory ack
);

// adder
reg [31:0] adder_1;
reg [31:0] adder_2;
wire [31:0] adder_o = adder_1 + adder_2;

// multiplier
reg [31:0] multiplier_1;
reg [31:0] multiplier_2;
wire [65:0] multiplier_o = multiplier_1 * multiplier_2;

// divider
reg [31:0] divider_1;
reg [31:0] divider_2;
wire [31:0] divider_o = divider_1 / divider_2;

// jump hold flag
reg jump_flag_o_d;
always @(posedge clk or negedge rst_n ) begin
  if( !rst_n ) begin
    jump_flag_o_d <= 0; 
  end
  jump_flag_o_d <= jump_flag_o;
end

always @(*) begin
  jump_hold_o = jump_flag_o_d | jump_flag_o;
end

reg mem_ack_d;
always @(posedge clk) begin
  mem_ack_d <= mem_ack_i;
end

// load/store hold flag
reg ls_flag;
always @(*)begin
  ls_hold_o = ls_flag & (!mem_ack_d);
end

always @(posedge clk)begin
  mem_sel_o <= ls_hold_o;
end

reg instr_error;

always @(*) begin
  adder_1 = 0;
  adder_2 = 0;
  multiplier_1 = 0;
  multiplier_2 = 0;
  divider_1 = 0;
  divider_2 = 0;
  reg_wen_o = 0;
  reg_waddr_o = 0;
  reg_wdata_o = 0;
  mem_addr_o = 0;
  mem_wdata_o = 0;
  mem_wsize_o = 0;
  mem_wmask_o = 0;
  mem_wen_o = 0;
  pc_next_o = 0;
  jump_flag_o = 0;
  ls_flag = 0;
  instr_error = 0;

  case (opcode_i)
    // I-type instructions
    `TYPE_I:begin
      case (funct3_i)
        `ADD: begin // imme + x[rs1]
          adder_1 = reg1_rdata_i;
          adder_2 = { {20{imme_i[11]}}, imme_i}; // signed

          reg_wen_o = 1'b1;
          reg_waddr_o = rd_i;
          reg_wdata_o = adder_o;
        end
        `SLT: begin // signed x[rs1] < signed imme
          reg_wen_o = 1'b1;
          reg_waddr_o = rd_i;
          reg_wdata_o = ($signed(reg1_rdata_i) < $signed(imme_i)) ? 32'b1 : 32'b0;
        end
        `SLTU: begin // unsigned x[rs1] < unsigned imme
          reg_wen_o = 1'b1;
          reg_waddr_o = rd_i;
          reg_wdata_o = reg1_rdata_i < imme_i ? 32'b1 : 32'b0;
        end
        `XOR: begin // x[rs1] ^ imme
          reg_wen_o = 1'b1;
          reg_waddr_o = rd_i;
          reg_wdata_o = reg1_rdata_i ^ imme_i;
        end
        `OR: begin // x[rs1] | imme
          reg_wen_o = 1'b1;
          reg_waddr_o = rd_i;
          reg_wdata_o = reg1_rdata_i | imme_i;
        end
        `AND: begin // x[rs1] & imme
          reg_wen_o = 1'b1;
          reg_waddr_o = rd_i;
          reg_wdata_o = reg1_rdata_i & imme_i;
        end
        `SLLI: begin // x[rs1] << imme
          reg_wen_o = 1'b1;
          reg_waddr_o = rd_i;
          reg_wdata_o = reg1_rdata_i << imme_i;
        end
        `SRLI: begin // x[rs1] >> imme
          reg_wen_o = 1'b1;
          reg_waddr_o = rd_i;
          reg_wdata_o = reg1_rdata_i >> imme_i;
        end
        `SRAI: begin // x[rs1] >>> imme
          reg_wen_o = 1'b1;
          reg_waddr_o = rd_i;
          reg_wdata_o = $signed(reg1_rdata_i) >>> imme_i;
        end
        default: begin
          instr_error = 1;
        end
      endcase
    end

    // R-type instructions
    `TYPE_R : begin
      case (funct7_i)
        7'b000_0000: begin // funct7[5] == 0
          case (funct3_i)
            `ADD: begin // x[rs1] + x[rs2]
              adder_1 = reg1_rdata_i;
              adder_2 = reg2_rdata_i;

              reg_wen_o = 1'b1;
              reg_waddr_o = rd_i;
              reg_wdata_o = adder_o;
            end
            `SLL: begin // x[rs1] << x[rs2]
              reg_wen_o = 1'b1;
              reg_waddr_o = rd_i;
              reg_wdata_o = reg1_rdata_i << reg2_rdata_i;
            end
            `SLT: begin // signed x[rs1] < signed x[rs2]
              reg_wen_o = 1'b1;
              reg_waddr_o = rd_i;
              reg_wdata_o = $signed(reg1_rdata_i) < $signed(reg2_rdata_i);
            end
            `SLTU: begin // unsigned x[rs1] < unsigned x[rs2]
              reg_wen_o = 1'b1;
              reg_waddr_o = rd_i;
              reg_wdata_o = reg1_rdata_i < reg2_rdata_i;
            end
            `XOR: begin // x[rs1] ^ x[rs2]
              reg_wen_o = 1'b1;
              reg_waddr_o = rd_i;
              reg_wdata_o = reg1_rdata_i ^ reg2_rdata_i;
            end
            `SRL: begin // x[rs1] >> x[rs2]
              reg_wen_o = 1'b1;
              reg_waddr_o = rd_i;
              reg_wdata_o = reg1_rdata_i >> reg2_rdata_i;
            end
            `OR: begin // x[rs1] | x[rs2]
              reg_wen_o = 1'b1;
              reg_waddr_o = rd_i;
              reg_wdata_o = reg1_rdata_i | reg2_rdata_i;
            end
            `AND: begin // x[rs1] & x[rs2]
              reg_wen_o = 1'b1;
              reg_waddr_o = rd_i;
              reg_wdata_o = reg1_rdata_i & reg2_rdata_i;
            end
            default: begin
              instr_error = 1;
            end
          endcase
        end
        7'b010_0000: begin // funct7[5] == 1
          case (funct3_i)
            `SUB: begin
              reg_wen_o = 1'b1;
              reg_waddr_o = rd_i;
              reg_wdata_o = reg1_rdata_i - reg2_rdata_i;
            end
            `SRA: begin
              reg_wen_o = 1'b1;
              reg_waddr_o = rd_i;
              reg_wdata_o = reg1_rdata_i >>> reg2_rdata_i;
            end
            default: begin
              instr_error = 1;
            end
          endcase
        end
        7'b000_0001: begin // M instr funct7[5:1] == 0
          case (funct3_i)
            `MUL: begin
              multiplier_1 = reg1_rdata_i;
              multiplier_2 = reg2_rdata_i;

              reg_wen_o = 1'b1;
              reg_waddr_o = rd_i;
              reg_wdata_o = multiplier_o[31:0];
            end
            `MULH: begin
              multiplier_1 = reg1_rdata_i;
              multiplier_2 = reg2_rdata_i;

              reg_wen_o = 1'b1;
              reg_waddr_o = rd_i;
              reg_wdata_o = multiplier_o[63:32];
            end
            `MULHSU: begin
              multiplier_1 = reg1_rdata_i;
              multiplier_2 = reg2_rdata_i;

              reg_wen_o = 1'b1;
              reg_waddr_o = rd_i;
              reg_wdata_o = multiplier_o[63:32];
            end
            `MULHU: begin
              multiplier_1 = reg1_rdata_i;
              multiplier_2 = reg2_rdata_i;

              reg_wen_o = 1'b1;
              reg_waddr_o = rd_i;
              reg_wdata_o = multiplier_o[63:32];
            end
            `DIV: begin
              divider_1 = reg1_rdata_i;
              divider_2 = reg2_rdata_i;

              reg_wen_o = 1'b1;
              reg_waddr_o = rd_i;
              reg_wdata_o = divider_o;
            end
            `DIVU: begin
              divider_1 = reg1_rdata_i;
              divider_2 = reg2_rdata_i;

              reg_wen_o = 1'b1;
              reg_waddr_o = rd_i;
              reg_wdata_o = divider_o;
            end
            `REM: begin
              reg_wen_o = 1'b1;
              reg_waddr_o = rd_i;
              reg_wdata_o = reg1_rdata_i % reg2_rdata_i;
            end
            `REMU: begin
              reg_wen_o = 1'b1;
              reg_waddr_o = rd_i;
              reg_wdata_o = reg1_rdata_i % reg2_rdata_i;
            end
            default: begin
              instr_error = 1;
            end
          endcase
        end
        default: begin
          instr_error = 1;
        end 
      endcase
    end

    //  L-type instructions
    `TYPE_L: begin // load memory to register
      ls_flag = 1'b1;

      adder_1 = reg1_rdata_i;
      adder_2 = { {20{imme_i[11]}}, imme_i}; // signed
      mem_addr_o = adder_o; // mem_addr_o = x[rs1] + imme
      
      reg_wen_o = 1'b1;
      reg_waddr_o = rd_i;
      case (funct3_i)
        `LB: begin // byte x[rd] = mem[x[rs1] + imme]
          case(mem_addr_o)
            2'b00: reg_wdata_o = { {24{mem_rdata_i[7]}},  mem_rdata_i[7:0]   };
            2'b01: reg_wdata_o = { {24{mem_rdata_i[15]}}, mem_rdata_i[15:8]  };
            2'b10: reg_wdata_o = { {24{mem_rdata_i[23]}}, mem_rdata_i[23:16] };
            2'b11: reg_wdata_o = { {24{mem_rdata_i[31]}}, mem_rdata_i[31:24] };
          endcase
        end
        `LH: begin // half word x[rd] = mem[x[rs1] + imme]           
          case(mem_addr_o[1]) // 00 01 10 11
            1'b0: reg_wdata_o = { {16{mem_rdata_i[15]}},  mem_rdata_i[15:0]};
            1'b1: reg_wdata_o = { {16{mem_rdata_i[31]}},  mem_rdata_i[31:16]};
          endcase
        end 
        `LW: begin // word
          reg_wdata_o = mem_rdata_i;
        end
        `LBU: begin // unsigned byte
          case(mem_addr_o)
            2'b00: reg_wdata_o = { 24'h0, mem_rdata_i[7:0]   };
            2'b01: reg_wdata_o = { 24'h0, mem_rdata_i[15:8]  };
            2'b10: reg_wdata_o = { 24'h0, mem_rdata_i[23:16] };
            2'b11: reg_wdata_o = { 24'h0, mem_rdata_i[31:24] };
          endcase
        end
        `LHU: begin // unsigned half word
          reg_wen_o = 1'b1;
          reg_waddr_o = rd_i;
          case(reg_waddr_o[1]) // 00 01 10 11
            1'b0: reg_wdata_o = { 16'h0, mem_rdata_i[15:0]};
            1'b1: reg_wdata_o = { 16'h0, mem_rdata_i[31:16]};
          endcase
        end
        default: begin
          instr_error = 1;
        end
      endcase
    end

    // S-type instructions
    `TYPE_S: begin // store register to memory
      ls_flag = 1'b1;

      adder_1 = reg1_rdata_i;
      adder_2 = { {20{imme_i[11]}}, imme_i}; // signed
      mem_addr_o = adder_o; // mem_addr_o = x[rs1] + imme
      mem_wen_o = 1'b1;
      case (funct3_i)
        `SB: begin // mem[x[rs1] + imme] = x[rs2]   
          mem_wsize_o = 2'b00; // byte
          case(mem_addr_o[1:0]) // 00 01 10 11
            2'b00: mem_wdata_o = {24'h0, reg2_rdata_i[7:0]};
            2'b01: mem_wdata_o = {reg2_rdata_i[31:16], reg2_rdata_i[7:0], reg2_rdata_i[7:0]};
            2'b10: mem_wdata_o = {reg2_rdata_i[31:24], reg2_rdata_i[7:0], reg2_rdata_i[15:0]};
            2'b11: mem_wdata_o = {reg2_rdata_i[7:0],   reg2_rdata_i[23:0]};
          endcase
          case(mem_addr_o[1:0]) // 00 01 10 11
            2'b00: mem_wmask_o = 4'b0001;
            2'b01: mem_wmask_o = 4'b0010;
            2'b10: mem_wmask_o = 4'b0100;
            2'b11: mem_wmask_o = 4'b1000;
          endcase
        end
        `SH: begin
          mem_wsize_o = 2'b01; // half word
          mem_wdata_o = mem_addr_o[1] ? {reg2_rdata_i[31:16], 16'h0} : {16'h0, reg2_rdata_i[15:0]};
          mem_wmask_o = mem_addr_o[1] ? 4'b0011 : 4'b1100;
        end
        `SW: begin
          mem_wsize_o = 2'b10; // word
          mem_wdata_o = reg2_rdata_i;
          mem_wmask_o = 4'b1111;
        end
        default: begin
          instr_error = 1;
        end
      endcase
    end

    // B-type instructions
    `TYPE_B: begin // branch
      case (funct3_i)
        `BEQ: begin // pc = x[rs1] == x[rs2] ? pc + imme : pc
          pc_next_o = (reg1_rdata_i == reg2_rdata_i) ? pc_i + imme_i : pc_i;
          jump_flag_o = (reg1_rdata_i == reg2_rdata_i) ? 1 : 0;
        end
        `BNE: begin // pc = x[rs1] != x[rs2] ? pc + imme : pc
          pc_next_o = (reg1_rdata_i != reg2_rdata_i) ? pc_i + imme_i : pc_i;
          pc_next_o = (reg1_rdata_i != reg2_rdata_i) ? 1 : 0;
        end
        `BLT: begin // pc = x[rs1] < x[rs2] ? pc + imme : pc
          pc_next_o = ($signed(reg1_rdata_i) < $signed(reg2_rdata_i)) ? pc_i + imme_i : pc_i;
          jump_flag_o = ($signed(reg1_rdata_i) < $signed(reg2_rdata_i)) ? 1 : 0;
        end
        `BLTU: begin // pc = x[rs1] < x[rs2] ? pc + imme : pc
          pc_next_o = ($signed(reg1_rdata_i) < $signed(reg2_rdata_i)) ? pc_i + imme_i : pc_i;
          jump_flag_o = ($signed(reg1_rdata_i) < $signed(reg2_rdata_i)) ? 1 : 0;
        end
        `BGE: begin // pc = x[rs1] >= x[rs2] ? pc + imme : pc
          pc_next_o = (reg1_rdata_i >= reg2_rdata_i) ? pc_i + imme_i : pc_i;
          jump_flag_o = (reg1_rdata_i >= reg2_rdata_i) ? 1 : 0;
        end
        `BGEU: begin // pc = x[rs1] >= x[rs2] ? pc + imme : pc
          pc_next_o = (reg1_rdata_i >= reg2_rdata_i) ? pc_i + imme_i : pc_i;
          jump_flag_o = (reg1_rdata_i >= reg2_rdata_i) ? 1 : 0;
        end
        default: begin
          instr_error = 1;
        end
      endcase
    end

    // J-type instructions
    `TYPE_JAL: begin // jump and link, x[rd] = pc + 4, pc = pc + imme
      reg_wen_o = 1'b1;
      reg_waddr_o = rd_i;
      reg_wdata_o = pc_i + 4;
      pc_next_o = pc_i + imme_i;
      jump_flag_o = 1;
    end

    // JALR-type instructions
    `TYPE_JALR: begin // jump and link register, x[rd] = pc + 4, pc = x[rs1] + imme
      reg_wen_o = 1'b1;
      reg_waddr_o = rd_i;
      reg_wdata_o = pc_i + 4;
      pc_next_o = (reg1_rdata_i + imme_i) & 32'hfffffffe;
      jump_flag_o = 1;
    end

    // U-type instructions
    `TYPE_LUI: begin // load upper immediate, x[rd] = imme << 12
      reg_wen_o = 1'b1;
      reg_waddr_o = rd_i;
      reg_wdata_o = {imme_i, 12'h0};
    end

    // U-type instructions
    `TYPE_AUIPC: begin // add upper immediate to pc, x[rd] = pc + (imme << 12)
      reg_wen_o = 1'b1;
      reg_waddr_o = rd_i;
      reg_wdata_o = pc_i + {imme_i, 12'h0};
    end

    default: begin
      instr_error = 1;  
    end
  endcase
end
    
endmodule
