module core (
    input  clk,
    input  rst_n
);

  wire [31:0] pc_next_o;
  wire jump_valid;
  wire jump_hold_o;
  wire ls_hold_o;
  wire [31:0] pc_if_o; 
  wire [31:0] pc_id_o;
  wire [31:0] pc_d_o;

  wire [31:0] instr_rom;
  wire [31:0] instr_o;

  wire instr_valid_i;
  wire instr_valid_o;
 
  wire [11:0] imme_o;
  wire [ 4:0] rd_addr_o;
  wire [ 4:0] rs1_addr_o;
  wire [ 4:0] rs2_addr_o;
  wire [ 2:0] funct3_o;
  wire [ 6:0] funct7_o;
  wire [ 6:0] opcode_o;

  wire [31:0] reg1_rdata_i;
  wire [31:0] reg2_rdata_i;
  wire [31:0] reg1_rdata_o;
  wire [31:0] reg2_rdata_o;
  wire [31:0] reg_raddr_o;
  wire [31:0] reg_waddr_o;
  wire [31:0] reg_wdata_o;
  wire reg_wen_o;

  // memory rw interface
  
  wire [31:0] mem_addr_o;   // memory read address
  wire [31:0] mem_rdata_i;  // memory read data
  wire [31:0] mem_wdata_o;  // memory write data
  wire [ 1:0] mem_wsize_o;  // memory write size
  wire [ 3:0] mem_wmask_o;  // memory write mask
  wire mem_sel_o;           // memory select
  wire mem_wen_o;           // memory write enable
  wire mem_ack_i;           // memory ack

  rom u_rom (
    .addr(pc_if_o),
    .instr(instr_rom)
  );

  ifu u_ifu (
    .clk(clk),
    .rst_n(rst_n),
    .instr_valid_i('b1),
    .instr_i(instr_rom),
    .instr_o(instr_o),
    .pc_next_i(pc_next_o),
    .jump_valid_i(jump_valid),
    .hold_valid_i(ls_hold_o),
    .pc_o(pc_if_o),
    .pc_d_o(pc_d_o),
    .instr_valid_o(instr_valid_o)
  );

  idu u_idu (
    .clk(clk),
    .rst_n(rst_n),
    .instr_i(instr_o),
    .pc_i(pc_d_o),
    .pc_o(pc_id_o),

    .jump_hold_i(jump_hold_o),
    .ls_hold_i(ls_hold_o),

    .reg1_rdata_i(reg1_rdata_i),
    .reg2_rdata_i(reg2_rdata_i),

    .imme_o(imme_o),
    .rd_o(rd_addr_o),
    .rs1_o(rs1_addr_o),
    .rs2_o(rs2_addr_o),
    .funct3_o(funct3_o),
    .funct7_o(funct7_o),
    .opcode_o(opcode_o),

    .reg1_rdata_o(reg1_rdata_o),
    .reg2_rdata_o(reg2_rdata_o)
  );

  exu u_exu (
    .clk(clk),
    .rst_n(rst_n),

    .pc_i(pc_id_o),
    .pc_next_o(pc_next_o),
    .jump_flag_o(jump_valid),
    .jump_hold_o(jump_hold_o),
    .ls_hold_o(ls_hold_o),

    .imme_i(imme_o),
    .rd_i(rd_addr_o),
    .rs1_i(rs1_addr_o),
    .rs2_i(rs2_addr_o),
    .funct3_i(funct3_o),
    .funct7_i(funct7_o),
    .opcode_i(opcode_o),
  
    .reg1_rdata_i(reg1_rdata_o),
    .reg2_rdata_i(reg2_rdata_o),

    .reg_wen_o(reg_wen_o),
    .reg_waddr_o(reg_waddr_o),
    .reg_wdata_o(reg_wdata_o),

    .mem_rdata_i(mem_rdata_i),
    .mem_addr_o(mem_addr_o),
    .mem_wdata_o(mem_wdata_o),
    .mem_wsize_o(mem_wsize_o),
    .mem_wmask_o(mem_wmask_o),
    .mem_sel_o(mem_sel_o),
    .mem_wen_o(mem_wen_o),
    .mem_ack_i(mem_ack_i)
    
  );

  regs u_regs (
    .clk(clk),
    .rst_n(rst_n),
    
    .rs1_addr(rs1_addr_o),
    .rs2_addr(rs2_addr_o),

    .wr_addr(reg_waddr_o),
    .wr_data(reg_wdata_o),
    .we(reg_wen_o),

    .rs1_data(reg1_rdata_i),
    .rs2_data(reg2_rdata_i)
  );

  wire byte_en = mem_wsize_o == 2'b00 ? 4'b0001:
                 mem_wsize_o == 2'b01 ? 4'b0011:
                 mem_wsize_o == 2'b10 ? 4'b1111: 4'b0000;

  sram u_sram (
    .clk(clk),
    .rst_n(rst_n),
    .sel(mem_sel_o),
    .we(mem_wen_o),
    .byte_en(mem_wmask_o),
    .addr(mem_addr_o),
    .din(mem_wdata_o),
    .dout(mem_rdata_i),
    .ack(mem_ack_i)
  );

endmodule
