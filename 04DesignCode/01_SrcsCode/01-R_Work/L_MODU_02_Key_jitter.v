`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2023/09/05 19:56:09
// Design Name: 
// Module Name: Key_jitter
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

//在按键信号变化后的一段时间内，如果按键信号不发生变化，则为有按键按下，按键状态寄存器置1；
//如果按键信号发生改变，记为抖动，按键状态寄存器仍为0
module BTN_JITTER(
  input CLK,
  input BTN_IN,//按键输入信号
  output BTN_POSEDGE//按键上升沿检测信号（输出）
    );
  //内部信号
  reg [1:0] BTN_IN_R;//按键输入的寄存器
  wire BTN_STATE;  //按键状态寄存器
  reg [19:0] count;//计数器
  reg BTN_VALUE_R = 0;//按键值的寄存器
  reg BTN_VALUE_RD = 0;//按键值的寄存器（延时一个时钟周期）
  //将当前的按键输入保存到BTN_IN寄存器中
  always @(posedge CLK)
    BTN_IN_R <= {BTN_IN_R[0], BTN_IN};
  //检测有输入有没有变化
  assign BTN_STATE = BTN_IN_R[0] ^ BTN_IN_R[1];
  
  always @(posedge CLK)
    if(BTN_STATE == 1'b1)
      count <= 20'h0;//连续检测到按键输入有变化，计数器清0
    else 
      count <= count + 1;
   //count达最大值时，将当前BTN_IN_r[0]赋给BTN_VALUE_r 
   always @(posedge CLK)
     if(count == 20'hffff)
       BTN_VALUE_R <= BTN_IN_R[0];
   //上升沿时赋值，实现一个时钟周期的延迟
   always @(posedge CLK)
     BTN_VALUE_RD <= BTN_VALUE_R;
   //将BTN_POSEDGE赋值为按键上升沿检测信号，按键在上升沿时为逻辑真
   assign BTN_POSEDGE = BTN_VALUE_r & ~BTN_VALUE_rd;
       
endmodule
