module sram #(
    parameter DATA_WIDTH = 32,
    parameter ADDR_WIDTH = 32,
    parameter BYTE_WIDTH = 8,
    parameter NUM_BYTES = DATA_WIDTH / BYTE_WIDTH
)(
    input wire clk,
    input wire we,
    input wire [NUM_BYTES-1:0] byte_en,
    input wire [ADDR_WIDTH-1:0] addr,
    input wire [DATA_WIDTH-1:0] din,
    output reg [DATA_WIDTH-1:0] dout
);

    // Declare the SRAM memory array
    reg [DATA_WIDTH-1:0] mem [(2**ADDR_WIDTH)-1:0];

    integer i;
    always @(posedge clk) begin
        if (we) begin
            for (i = 0; i < NUM_BYTES; i = i + 1) begin
                if (byte_en[i]) begin
                    mem[addr][i*BYTE_WIDTH +: BYTE_WIDTH] <= din[i*BYTE_WIDTH +: BYTE_WIDTH]; // Byte write operation
                end
            end
        end
        dout <= mem[addr]; // Read operation
    end

endmodule