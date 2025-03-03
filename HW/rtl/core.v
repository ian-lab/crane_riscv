module core (
    input  clk,
    input  rst_n
);

  wire [31:0] pc_next_o;
  wire [31:0] pc_o;
  wire [31:0] instr_i;
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
  wire [31:0] mem_rdata_i; // memory read data
  wire [31:0] mem_raddr_o; // memory read address
  wire [31:0] mem_waddr_o; // memory write address
  wire [31:0] mem_wdata_o; // memory write data
  wire [ 1:0] mem_wsize_o; // memory write size
  wire mem_wen_o;           // memory write enable

  rom u_rom (
    .addr(pc_o),
    .instr(instr_i)
  );

  ifu u_ifu (
    .clk(clk),
    .rst_n(rst_n),
    .instr_valid_i('b1),
    .instr_i(instr_i),
    .pc_i(pc_next_o),
    .pc_o(pc_o),
    .instr_valid_o(instr_valid_o)
  );

  idu u_idu (
    .clk(clk),
    .rst_n(rst_n),
    .instr_i(instr_i),

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

    .pc_i(pc_o),
    .pc_next_o(pc_next_o),

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
    .mem_raddr_o(mem_raddr_o),
    .mem_waddr_o(mem_addr_o),
    .mem_wdata_o(mem_wdata_o),
    .mem_wsize_o(mem_wsize_o),
    .mem_wen_o(mem_wen_o)
    
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

endmodule
