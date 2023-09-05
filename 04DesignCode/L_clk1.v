`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2023/09/04 13:24:59
// Design Name: 
// Module Name: L_clk1
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


module L_clk1(clk,rst_n,clk1);
input clk;
input rst_n;
output clk1;
reg clk1;
reg [19:0] count;
always @(posedge clk or negedge rst_n)
begin
  if(!rst_n)
    begin
      clk1 <= 1'b0;
      count <= 0;
    end
  else if(count == 499999)
    begin
      clk1 <= ~clk1;
      count <= count + 1;
    end
    else if(count == 999999)
      begin
        clk1 <= ~clk1;
        count <= 0;
      end
    else
      begin
        clk1 <= clk1;
        count <= count + 1;
        end
     
end

endmodule


