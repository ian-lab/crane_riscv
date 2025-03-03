`timescale 1ns/1ps

module tb();

  reg clk;
  reg rst_n;
  
  core u_core (
    .clk(clk),
    .rst_n(rst_n)
  );

  initial begin
    rst_n = 0;
    #10 rst_n = 1;
  end

  initial begin
    clk = 0;
    forever begin
      #5 clk = ~clk;
    end
  end

  //initial begin
  //  $dumpfile("tb.vcd");
  //  $dumpvars(0, tb);
  //end

  initial begin
    $fsdbDumpfile("dump.fsdb") ; 
    $fsdbDumpvars(0, tb);
  end

  initial begin
    #100; 
    $finish;
  end

endmodule
