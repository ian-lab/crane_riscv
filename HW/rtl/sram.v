module sram #(
    parameter DATA_WIDTH = 32,
    parameter ADDR_WIDTH = 32,
    parameter BYTE_WIDTH = 8,
    parameter NUM_BYTES = DATA_WIDTH / BYTE_WIDTH
)(
    input wire clk,
    input wire rst_n,
    input wire sel,
    input wire we,
    input wire [NUM_BYTES-1:0] byte_en,
    input wire [ADDR_WIDTH-1:0] addr,
    input wire [DATA_WIDTH-1:0] din,
    output reg [DATA_WIDTH-1:0] dout,
    output reg ack
);

  // Declare the SRAM memory array
  reg [DATA_WIDTH-1:0] mem [1024-1:0];

  integer i;
  always @(posedge clk or negedge rst_n) begin
    if(!rst_n)begin
      for (i = 0; i < 10; i = i + 1) begin
        mem[i] <= 0;
      end
    end
    else if (we) begin
      for (i = 0; i < NUM_BYTES; i = i + 1) begin
        if (byte_en[i]) begin
          mem[addr][i*BYTE_WIDTH +: BYTE_WIDTH] <= din[i*BYTE_WIDTH +: BYTE_WIDTH]; // Byte write operation
        end
      end
    end
    dout <= mem[addr]; // Read operation
  end

  reg sel_d;
  always @(posedge clk ) begin
    sel_d <= sel;
  end
  
  always @(posedge clk ) begin
    ack <= sel & (!sel_d);
  end
endmodule
