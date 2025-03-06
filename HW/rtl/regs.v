module regs (
    input  clk,
    input  rst_n,
    input  [4:0] rs1_addr,
    input  [4:0] rs2_addr,
    input  [4:0] wr_addr,
    input  [31:0] wr_data,
    input  we,
    output reg [31:0] rs1_data,
    output reg [31:0] rs2_data
);

  reg [31:0] reg_file [31:0];
  integer i;

  // Read port
  always @(*) begin
    if(rs1_addr == 0) begin
      rs1_data = 32'b0;
    end
    else if( (rs1_addr == wr_addr) && we) begin // return the write data when write happens
      rs1_data = wr_data;
    end
    else begin
      rs1_data = reg_file[rs1_addr];
    end
  end

  always @(*) begin
    if(rs2_addr == 0) begin
      rs2_data = 32'b0;
    end
    else if( (rs2_addr == wr_addr) && we) begin
      rs2_data = wr_data;
    end
    else begin
      rs2_data = reg_file[rs2_addr];
    end
  end

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