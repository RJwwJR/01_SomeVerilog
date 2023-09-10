`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2023/09/10 15:57:06
// Design Name: 
// Module Name: SWITCH_IO_V4
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


module SWITCH_IO_V4(
  input CLK,
  input RESET,
  input [9:0] SW,
  input [9:0] SW_HISTORY,
  input [3:0] SCAN_COUNTER,

  output reg [1:0] SW_CHANGE_FLAG,
  output reg [3:0] WHICH_SW_CHANGE,
  output reg [7:0] UP_QUEUE,

  output reg [19:0] SW_DIFFERENCE
  );
//……………………………………………………………………………………………………………………………………………………………………………………………………………………………………………………………………………
  //R：参数定义
  parameter HalfByte = 4;
  parameter None = 4'hf;
  //R：对应各种情况，default 的情况包含 UnChange 和其他未知干扰
  parameter Down = 0; 
  parameter Up = 1;
	parameter UnChange = 2;
//……………………………………………………………………………………………………………………………………………………………………………………………………………………………………………………………………………
  ////R：内部信号
  //R：循环计数器
  genvar i;

//……………………………………………………………………………………………………………………………………………………………………………………………………………………………………………………………………………
  generate for ( i = 0; i < 10 ; i = i + 1)
  begin:SWITCH_IO_V4_Generate_Block_1
    always @ (posedge CLK or posedge RESET)
    //R：第一个 always 块，用于电平信号的检出，其中 always 过程块只能写在 generate 块内部
    begin
      if(RESET)   
      //R：系统 同步 RESET 的含义，将内部的数据全部置为初始态
        begin
          //R：对于内部信号，在收到同步复位也需要进行复位
          SW_DIFFERENCE <= 20'b0;
        end
      else
        begin
          if (SW[i] < SW_HISTORY[i]) 
          SW_DIFFERENCE[(i * HalfByte/2) +: HalfByte/2] <= Down;
          else if (SW[i] > SW_HISTORY[i]) 
          SW_DIFFERENCE[(i * HalfByte/2) +: HalfByte/2] <= Up;
          else 
          SW_DIFFERENCE[(i * HalfByte/2) +: HalfByte/2] <= UnChange;
        end
    end
  end
  endgenerate

//……………………………………………………………………………………………………………………………………………………………………………………………………………………………………………………………………………
  always @ (posedge CLK or posedge RESET)
  begin
    if(RESET)
    begin
      SW_CHANGE_FLAG[0] <= 1'b0;
      SW_CHANGE_FLAG[1] <= 1'b0;
      WHICH_SW_CHANGE <= None;

      //R：硬件状态记录保持不变，这样同步 RESET_N 之后利用 硬件状态 实施的 冲突/矛盾处理 才是有效的
      UP_QUEUE <= UP_QUEUE;
    end
    else
    begin
      case(SW_DIFFERENCE[(SCAN_COUNTER * HalfByte/2) +: HalfByte/2])
      "Up":
      begin
        SW_CHANGE_FLAG[0] <= 1'b1;
        SW_CHANGE_FLAG[1] <= 1'b1;
        WHICH_SW_CHANGE <= SCAN_COUNTER;
        //……………………………………………………………………………………………
        if(UP_QUEUE[3:0] == 4'd0)
        begin
          UP_QUEUE[7:4] <= SCAN_COUNTER; 
          UP_QUEUE[3:0] <= UP_QUEUE[3:0] + 1;
        end
        //……………………………………………………………………………………………
        else
        begin
          //R:不接收新的 Up 
          UP_QUEUE[7:4] <= UP_QUEUE[7:4];
          //R: 但仍要更新 Up 入队计数
          UP_QUEUE[3:0] <= UP_QUEUE[3:0] + 1;
        end
      end
      //………………………………………………………………………………………………………………………………
      "Down":
      begin
        //R：单次状态描述，必须改变
        //SW_CHANGE_FLAG <= { Down , 1 };
        SW_CHANGE_FLAG[0] <= 1'b1;
        SW_CHANGE_FLAG[1] <= 1'b0;
        WHICH_SW_CHANGE <= SCAN_COUNTER;
        //……………………………………………………………………………………………
        //R：UP_QUEUE，根据情况相应改变
        if((UP_QUEUE[3:0] == 4'd0) || (UP_QUEUE[3:0] == 4'd1))
          begin
            UP_QUEUE[3:0] <= 4'd0;
            UP_QUEUE[7:4] <= None;
          end
        //……………………………………………………………………………………………
        else
          begin
            UP_QUEUE[3:0] <= UP_QUEUE[3:0] - 1;
            UP_QUEUE[7:4] <= UP_QUEUE[7:4];
          end
      end
      //………………………………………………………………………………………………………………………………
      default
      begin
        //R：注意，单次状态描述，Flag[1] = 0 , WHICH_SW_CHANGE <= 4'hf，都是特殊含义复用，实际检测中要配合使用
        //SW_CHANGE_FLAG <= { 0 , 0 };
        SW_CHANGE_FLAG[0] <= 1'b0;
        SW_CHANGE_FLAG[1] <= 1'b0;
        WHICH_SW_CHANGE <= None;
        UP_QUEUE <= UP_QUEUE;
      end
      endcase
    end
  end
  
endmodule
