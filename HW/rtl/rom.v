module rom (
    input [31:0] addr,
    output reg [31:0] instr
);

reg [31:0] rom [31:0];

// initial $readmemb("", bin_mem);
initial begin
  // Load instructions into ROM
  // rom[0] = 32'b00000000000100000000000010010011; // addi x1, x0, 1
  // rom[1] = 32'b00000000001000000000000100010011; // addi x2, x0, 2
  // rom[2] = 32'b00000000001100000000000110010011; // addi x3, x0, 3
  // rom[3] = 32'b00000000010000000000001000010011; // addi x4, x0, 4
  // rom[4] = 32'b00000000010100000000001010010011; // addi x5, x0, 5
  // rom[5] = 32'b00000000011000000000001100010011; // addi x6, x0, 6
  // rom[6] = 32'b00000000011100000000001110010011; // addi x7, x0, 7
  // rom[7] = 32'b00000000100000000000010000010011; // addi x8, x0, 8
  // rom[8] = 32'b00000000100100000000010010010011; // addi x9, x0, 9
  // rom[9] = 32'b00000000101000000000010100010011; // addi x10, x0, 10
  // rom[10] = 32'b00000000101100000000010110010011; // addi x11, x0, 11
  // rom[11] = 32'b00000000110000000000011000010011; // addi x12, x0, 12

  // rom[0]  = 32'h00500293;  // addi x5, x0, 5
  // rom[1]  = 32'h00300313;  // addi x6, x0, 3
  // rom[2]  = 32'h00800393;  // addi x7, x0, 8
  // rom[3]  = 32'h00200413;  // addi x8, x0, 2
  // rom[4]  = 32'h006282b3;  // add x5, x5, x6   (x5 = x5 + x6)
  // rom[5]  = 32'h4083c333;  // sub x6, x7, x8   (x6 = x7 - x8)
  // rom[6]  = 32'h0062f4b3;  // and x9, x5, x6   (x9 = x5 & x6)
  // rom[7]  = 32'h0083e533;  // or x10, x7, x8   (x10 = x7 | x8)
  // rom[8]  = 32'h0062c5b3;  // xor x11, x5, x6  (x11 = x5 ^ x6)
  // rom[9]  = 32'h00a2a623;  // sw x10, 12(x5)   (Mem[x5 + 12] = x10)
  // rom[10] = 32'h00f32413;  // andi x8, x6, 15  (x8 = x6 & 15)
  // rom[11] = 32'h0143e493;  // ori x9, x7, 20   (x9 = x7 | 20)
  // rom[12] = 32'h01944713;  // xori x14, x8, 25 (x14 = x8 ^ 25)
  // rom[13] = 32'h0002a783;  // lw x15, 0(x5)    (x15 = Mem[x5 + 0])
  // rom[14] = 32'h00f2a223;  // sw x15, 4(x5)    (Mem[x5 + 4] = x15)
  // rom[15] = 32'h00630a63;  // beq x6, x7, label (if x6 == x7, 跳转)
  // rom[16] = 32'h00841c63;  // bne x8, x9, label (if x8 != x9, 跳转)
  // rom[17] = 32'h00000013;  // nop
  
  // 读取十六进制文件
    $readmemh("/home/autumn/project/crane_riscv/HW/rtl/rom_data.hex", rom);
end

always @(*) begin
    instr = rom[addr[31:2]];
    $display("rom[%d] = %h", addr[31:2], instr);
end
    
endmodule
