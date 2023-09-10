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
        if(Current_State == WAIT)           //�ȴ�״̬������Ϊ��ɫ
          begin
            RGB1_RED <= 1'b0;
            RGB1_GREEN <= 1'b0;
            RGB1_BLUE <= 1'b1;
            RGB2_RED <= 1'b0;
            RGB2_GREEN <= 1'b0;
            RGB2_BLUE <= 1'b1;         
          end   
        else if(Current_State == INPUT)        //����״̬һ��Ϊ��ɫ��һ��Ϊ��ɫ
          begin
            RGB1_RED <= 1'b1;
            RGB1_GREEN <= 1'b0;
            RGB1_BLUE <= 1'b0;
            RGB2_RED <= 1'b0;
            RGB2_GREEN <= 1'b1;
            RGB2_BLUE <= 1'b0;   
          end         
        else if(Current_State == UNLOCK)       //����״̬������Ϊ��ɫ
          begin
            RGB1_RED <= 1'b0;
            RGB1_GREEN <= 1'b1;
            RGB1_BLUE <= 1'b0;
            RGB2_RED <= 1'b0;
            RGB2_GREEN <= 1'b1;
            RGB2_BLUE <= 1'b0;
          end
        else if(Current_State == ERROR)        //����״̬������Ϊ��ɫ
          begin
            RGB1_RED <= 1'b1;
            RGB1_GREEN <= 1'b1;
            RGB1_BLUE <= 1'b0;
            RGB2_RED <= 1'b1;
            RGB2_GREEN <= 1'b1;
            RGB2_BLUE <= 1'b0;
          end
        else if(Current_State == ALARM)        //����״̬������Ϊ��ɫ
          begin
            RGB1_RED <= 1'b1;
            RGB1_GREEN <= 1'b0;
            RGB1_BLUE <= 1'b0;
            RGB2_RED <= 1'b1;
            RGB2_GREEN <= 1'b0;
            RGB2_BLUE <= 1'b0;
          end
        else if(Current_State == ADMIN)      //����Ա״̬������Ϊ��ɫ
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
