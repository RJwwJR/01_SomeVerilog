`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2023/09/04 13:24:59
// Design Name: 
// Module Name: L_CLK_OUT
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


module M_CLK(CLK_IN, RESET_N, CLK_OUT);
input CLK_IN;
input RESET_N; 
output CLK_OUT;
reg CLK_OUT;
reg [19:0] count;
always @(posedge CLK_IN or negedge RESET_N) 
begin
  if(!RESET_N) 
    begin
      CLK_OUT <= 1'b0;
      count <= 0;
    end
  else if(count == 499999)
    begin
      CLK_OUT <= ~CLK_OUT;
      count <= count + 1;
    end
    else if(count == 999999)
      begin
        CLK_OUT <= ~CLK_OUT;
        count <= 0;
      end
    else
      begin
        CLK_OUT <= CLK_OUT;
        count <= count + 1;
        end
     
end

endmodule


