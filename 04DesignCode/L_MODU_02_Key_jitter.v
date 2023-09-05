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
module Key_jitter(
  input clk,
  input key_in,//按键输入信号
  output key_posedge//按键上升沿检测信号（输出）
    );
  //内部信号
  reg [1:0] key_in_r;//按键输入的寄存器
  wire kk;  //按键状态寄存器
  reg [19:0] count;//计数器
  reg key_value_r = 0;//按键值的寄存器
  reg key_value_rd = 0;//按键值的寄存器（延时一个时钟周期）
  //将当前的按键输入保存到key_in寄存器中
  always @(posedge clk)
    key_in_r <= {key_in_r[0],key_in};
  //检测有输入有没有变化
  assign kk = key_in_r[0]^key_in_r[1];
  
  always @(posedge clk)
    if(kk == 1'b1)
      count <= 20'h0;//连续检测到按键输入有变化，计数器清0
    else 
      count <= count + 1;
   //count达最大值时，将当前key_in_r[0]赋给key_value_r 
   always @(posedge clk)
     if(count == 20'hffff)
       key_value_r <= key_in_r[0];
   //上升沿时赋值，实现一个时钟周期的延迟
   always @(posedge clk)
     key_value_rd <= key_value_r;
   //将key_posedge赋值为按键上升沿检测信号，按键在上升沿时为逻辑真
   assign key_posedge = key_value_r & ~key_value_rd;
       
endmodule
