`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2023/09/04 20:45:56
// Design Name: 
// Module Name: Switch
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


module Switch_in(clk,SW,one_code);
input clk;
input [9:0] SW;
output one_code;
reg [3:0] one_code;
always @(clk)
  begin
    case(SW)
      10'b0000000001: one_code <= 4'b0000;
      10'b0000000010: one_code <= 4'b0001;
      10'b0000000100: one_code <= 4'b0010;
      10'b0000000001: one_code <= 4'b0011;
      10'b0000000001: one_code <= 4'b0100;
      10'b0000000001: one_code <= 4'b0101;
      10'b0000000001: one_code <= 4'b0110;
      10'b0000000001: one_code <= 4'b0111;
      10'b0000000001: one_code <= 4'b1000;
      10'b0000000001: one_code <= 4'b1001;
      default: one_code <= 4'b0000;
    endcase
  end
  
endmodule
