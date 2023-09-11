`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2023/09/10 19:41:43
// Design Name: 
// Module Name: L_MODU04_RGB
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


module L_MODU04_RGB(
    input CLK,
    input Current_State,
    output reg RGB1_RED,
    output reg RGB1_GREEN,
    output reg RGB1_BLUE,
    output reg RGB2_RED,
    output reg RGB2_GREEN,
    output reg RGB2_BLUE    
    );
    
    parameter WAIT = 3'b000;
    parameter INPUT = 3'b001;
    parameter UNLOCK = 3'b010;
    parameter ERROR = 3'b011;
    parameter ALARM = 3'b100;
    parameter ADMIN = 3'b101;
    
    always @(posedge CLK)
      begin
        if(Current_State == WAIT)           //等待状态两个均为蓝色
          begin
            RGB1_RED <= 1'b0;
            RGB1_GREEN <= 1'b0;
            RGB1_BLUE <= 1'b1;
            RGB2_RED <= 1'b0;
            RGB2_GREEN <= 1'b0;
            RGB2_BLUE <= 1'b1;         
          end   
        else if(Current_State == INPUT)        //输入状态一个为红色，一个为绿色
          begin
            RGB1_RED <= 1'b1;
            RGB1_GREEN <= 1'b0;
            RGB1_BLUE <= 1'b0;
            RGB2_RED <= 1'b0;
            RGB2_GREEN <= 1'b1;
            RGB2_BLUE <= 1'b0;   
          end         
        else if(Current_State == UNLOCK)       //开锁状态两个均为绿色
          begin
            RGB1_RED <= 1'b0;
            RGB1_GREEN <= 1'b1;
            RGB1_BLUE <= 1'b0;
            RGB2_RED <= 1'b0;
            RGB2_GREEN <= 1'b1;
            RGB2_BLUE <= 1'b0;
          end
        else if(Current_State == ERROR)        //错误状态两个均为黄色
          begin
            RGB1_RED <= 1'b1;
            RGB1_GREEN <= 1'b1;
            RGB1_BLUE <= 1'b0;
            RGB2_RED <= 1'b1;
            RGB2_GREEN <= 1'b1;
            RGB2_BLUE <= 1'b0;
          end
        else if(Current_State == ALARM)        //报警状态两个均为红色
          begin
            RGB1_RED <= 1'b1;
            RGB1_GREEN <= 1'b0;
            RGB1_BLUE <= 1'b0;
            RGB2_RED <= 1'b1;
            RGB2_GREEN <= 1'b0;
            RGB2_BLUE <= 1'b0;
          end
        else if(Current_State == ADMIN)      //管理员状态两个均为白色
          begin
            RGB1_RED <= 1'b1;
            RGB1_GREEN <= 1'b1;
            RGB1_BLUE <= 1'b1;
            RGB2_RED <= 1'b1;
            RGB2_GREEN <= 1'b1;
            RGB2_BLUE <= 1'b1;
          end
      end
endmodule
