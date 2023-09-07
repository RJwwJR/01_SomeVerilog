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
  //input CLK,//R：组合逻辑，译码器，似乎不涉及时钟的操作。
  input RESET;
  input [9:0] SW,
  input [9:0] SW_History,

  //R：为了避免之后 always 块内赋值进行 reg、wire 的转换，直接定义成 reg
  output reg [7:0] Up_Queue,
  output wire [9:0] SW_History_Out,
  output reg [15:0] Code,
  output reg [2:0] Code_Bit);

  //R：循环计数器
  reg [3:0] i;
  //R：比较结果标志 Flag
  reg [1:0] j;
  parameter Byte = 4;
  //R：对应 j 的各种情况
  parameter Up = 1;
  parameter Down = 0; //R：似乎 parameter 不能给出负常量
  
  ////R:当发生改变，立即处理信号，由于 SWITCH 电平改变未必和时钟一致，因此应该为组合逻辑
  always@ (SW or negedge RESET)
  begin
   if(!RESET)//R：RESET 触发的情况
    begin
      //R：硬件状态记录保持不变，这样异步 RESET 之后利用 硬件状态 实施的 冲突/矛盾处理 才是有效的
      Up_Queue = Up_Queue;
      //R：系统 异步RESET 的含义，将内部的数据全部置为初始态
      Code = 16'hffff; //R：注意 Code 的初始态并不存在于密码的总集中，由于只有四位总线，取这一个特殊值也是可以的
      Code_Bit = 3'b0;
    end
   else
    begin
      for ( i = 4'd0; i <= 4'd9 ; i = i + 1)
        begin
          //R：通过比较，将负值的情况映射到 0/1/2 三种，避免使用 integrer
          if (SW[i] > SW_History[i]) j = 1;
          else if (SW[i] < SW_History[i]) j = 0;
          else j = 2;
          case(j)
          "Up":
            begin
              if(Up_Queue[3:0] == 4'd0) //R：Up 的 SW 数量 == 0，已经初始化做好了接收新 Up 的准备
                begin 
                  if(0 <= Code_Bit < 4)//R：已初始化 && 正常输入状态 == 可以录入
                    begin
                      //R:处理外部硬件状态，i.e.，Up_Queue
                      Up_Queue[7:4] = i;//R:接收新的 Up 
                      Up_Queue[3:0] = Up_Queue[3:0] + 1;//R: Up 队列入队计数++
                      //R：更新内部信号状态，i.e.，实现 I/O
                      Code_Bit = Code_Bit + 1;//R：进一位，准备录入
                      Code[(Code_Bit * Byte - 1) -:Byte] = Up_Queue[7:4];//R：按照 i 的情况按位录入相应的密码
                    end
                  else//R：已初始化 && 超出输入位数（小于0 / 大于等于4） == 硬件有改变 但不能录入
                    begin
                      //R：外部硬件状态仍需要处理，只不过内部信号不做相应的更新
                      Up_Queue[7:4] = i;//R:接收新的 Up，注意！接收不接收 Up 是由 Up_Queue[3:0] 决定
                      Up_Queue[3:0] = Up_Queue[3:0] + 1;//R: Up 队列入队计数++
                      //R：不更新内部 I/O
                      Code_Bit = Code_Bit;
                      Code = Code;
                    end
                end
              else//R：此前已经有 Up 的 SW，根本不用 Code_Bit 自检，直接锁死内部 I/O
              //R：但外部硬件状态还是需要记录的
              begin
                Up_Queue[7:4] = Up_Queue[7:4];//R:不接收新的 Up 
                Up_Queue[3:0] = Up_Queue[3:0] + 1;//R: 但仍要更新 Up 入队计数
                //R：不更新内部 I/O
                Code_Bit = Code_Bit;
                Code = Code;
              end
            end
          "Down":
            begin
              Code_Bit = Code_Bit;
              Code = Code;
              if((Up_Queue[3:0] == 4'd0) || (Up_Queue[3:0] == 4'd1))
                begin
                  Up_Queue[3:0] = 4'd0;
                  Up_Queue[7:4] = 4'hF;
                end
              else
                begin
                  Up_Queue[3:0] = Up_Queue[3:0] - 1;
                  Up_Queue[7:4] = Up_Queue[7:4];
                end
            end
          default://R：某个 SW 不变的情况，外部硬件状态 & 内部 I/O 都不做改变
            begin
              Up_Queue = Up_Queue;
              Code_Bit = Code_Bit;
              Code = Code;
            end
          endcase
        end
    end
  end

  //R：此 assign 与上面的 always 并行，实际上只是避免修改 input SW，所以单独设置信号将其引出
  assign SW_History_Out = SW;
endmodule
