module regs (
    input  clk,
    input  rst_n,
    input  [4:0] rs1_addr,
    input  [4:0] rs2_addr,
    input  [4:0] wr_addr,
    input  [31:0] wr_data,
    input  we,
    output  [31:0] rs1_data,
    output  [31:0] rs2_data
);

  reg [31:0] reg_file [31:0];
  integer i;

  // Read ports
  assign rs1_data = (rs1_addr != 0) ? reg_file[rs1_addr] : 32'b0;
  assign rs2_data = (rs2_addr != 0) ? reg_file[rs2_addr] : 32'b0;

  // Write port
  always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
      for (i = 0; i < 32; i=i+1) begin
        reg_file[i] <= 32'b0;
      end
      end else if (we && (wr_addr != 0)) begin
        reg_file[wr_addr] <= wr_data;
      end
  end

endmodule