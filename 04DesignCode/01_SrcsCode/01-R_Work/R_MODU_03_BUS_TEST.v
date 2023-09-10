`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2023/09/09 15:54:04
// Design Name: 
// Module Name: BUS_TEST
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module BUS_TEST(
  input CLK,
  output reg [9:0] BUS_OUT
  );

  reg [3:0] Temp = 4'b0;
  //R：在这里声明大小，在仿真里不会出现 X，但 RTL 原理图会有警告，不确定是否可以
  reg BUS_OUT = 10'b0;

  always @ (posedge CLK) 
  begin
  BUS_OUT[Temp] <= 1'b1;
  Temp <= (Temp + 1) % 10;
  end
endmodule
