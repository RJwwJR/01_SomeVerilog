`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2023/09/04 22:24:04
// Design Name: 
// Module Name: SWITCH_IO
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


module SWITCH_IO(
  input CLK,
  input [9:0] SW,
  input [9:0] SW_History_In,

  output [4:0] Up_Queue,
  output [4:0] Down_Queue,
  output [9:0] SW_History_Out,
  output [15:0] Code,
  output [2:0] Code_Bit);
  integer i;
  
  ////R:�������ı䣬���������źţ����� SWITCH ��ƽ�ı�δ�غ�ʱ��һ�£����Ӧ��Ϊ����߼�
  always@ (SW)
  begin
    for ( i = 0; i <= 9 ; i = i + 1)
    begin
    end
  end

endmodule
