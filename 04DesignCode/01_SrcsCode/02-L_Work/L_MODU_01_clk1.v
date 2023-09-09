`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2023/09/04 13:24:59
// Design Name: 
// Module Name: L_CLK1
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


module L_MOUDU_CLK1MS(CLK,RST_N,CLK1MS);
input CLK;
input RST_N;
output CLK1;
reg CLK1;
reg [19:0] count;
always @(posedge clk or negedge RST_N)
begin
  if(!RST_N)
    begin
      CLK1 <= 1'b0;
      count <= 0;
    end
  else if(count == 25000)
    begin
      CLK1 <= ~CLK1;
      count <= count + 1;
    end
    else if(count == 50000)
      begin
        CLK1 <= ~CLK1;
        count <= 0;
      end
    else
      begin
        CLK1 <= CLK1;
        count <= count + 1;
        end
     
end

endmodule


