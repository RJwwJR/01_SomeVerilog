`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2023/09/04 13:52:36
// Design Name: 
// Module Name: System
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


module System(
  input CLK,
  input [9:0] SW,
  //R：一般BTN & RESET 都是使用 BUTTON 进行控制，为了区分 BTN 电平信号 和转换到内部的 复位信号，统一成总线表示 BTN
  input [3:0] BTN,
  
  output [7:0] AN,
  output [7:0] SEG,
  output [15:0] LD
  );

  ////R：用于将外部电平信号与内部可处理信号进行译码耦合、分频、辅助处理的内部信号

  ///R：为处理 SW 电平信号，设置的内部信号
  //R：用 0/1 Flag 表征 SW 电平信号是否改变，0——不变，1——改变
  //reg Code_Change_Flag;//R：不足够，因为对于冲突的处理，需要明确知道具体哪个 SW 发生了 UP/DOWN 怎样的变化
  //R：用更为细致的方式进行表述，为了判断具体哪个 SW 发生了怎样的变化，需要记录历史 电平 情况进行比较
  //R：为了在比较后将 SW_History 进行更新，在 input/output 中各放一个 History 的变量，方便块执行后更新
  reg [9:0] SW_History;
  reg [9:0] SW_History_Out;
  //R：两位 bus，[0]————是否改变的 Flag，[1]————Up/Down 的 Flag
  reg [1:0] SW_Change_Flag;
  //R：有用的是总线值的大小，4'd[0~9]
  reg [3:0] Which_SW_Change;
  //R：[7:4]————第一个 Up，[3:0]————有几个 Up
  reg [7:0] Up_Queue;
  
  //R：读取 SW 电平信号后存储在内部的 Code & Key
  reg [15:0] Key;
  reg [15:0] Code;
  //R：记录已经输入的 Code bit，具有的取值范围————0,1,2,3,4，所以需要三位总线
  reg [2:0] Code_Bit;

  ///R：为处理 BTN 电平信号，设置的一组内部信号
  //R：用 0/1 Flag 表征 BTN 电平信号是否改变，0——不变，1——改变
  reg BTN_Change_Flag;
  //R：用 Which 表征具体哪一个 BTN 上升沿被触发，注意 RESET 已经被分立出去
  reg [1:0] Which_BTN_Posedge;
  //R：有 4 种情况，0/1/2/3，十进制表示
  //R：对应关系———— BTN_RESET——BTN[0]，BTN_ADMIN——BTN[1]，BTN_OK——BTN[2]，BTN_BACKSPACE——BTN[3]
  parameter BTN_RESET = 0;
  parameter BTN_ADMIN = 1;
  parameter BTN_OK = 2;
  parameter BTN_BACKSPACE = 3;
  
  ///R：用于辅助处理的内部信号
  //R：二值逻辑， 0/1 Flag 表征密码匹配是否正确
  reg Correct_Flag;
  //R：十进制信号，用于错误次数的统计，可以有 1/2/3 三种取值情况
  reg [1:0] Rrror_Time;
  //R：用于分频后产生新的时钟信号，周期 1ms，整个系统时钟还是 ns 级别，对于需要 ms 级别的时钟的模块，单独进行实例化即可
  //reg [4:0] M_Clock;
  
  
  //R：状态寄存
  reg [2:0] Current_State;
  reg [2:0] Next_State;
  
  //R：状态声明
  parameter WAIT = 3'b000;
  parameter INPUT = 3'b001;
  parameter UNLOCK = 3'b010;
  parameter ERROR = 3'b011;
  parameter ALARM = 3'b100;

  //R:状态寄存 & 转换逻辑
  always @ (posedge CLK or posedge RESET)
  begin 
    if(RESET == 1)
      Current_State <= WAIT;
    else
    Current_State <= Next_State;
  end

  //R：次态逻辑,复位已经在次态逻辑中写掉，此处已经无需再考虑
  /*always @ (Current_State or Code_Change_Flag or BTN_Change_Flag)
  begin
    case(Current_State)
      WAIT:
      begin

      end
      INPUT:
      begin

      end
      ERROR:
      begin

      end
      UNLOCK:
      begin

      end
      ALARM:
      begin

      end
      default:
        Current_State = WAIT;
    endcase
  end*/
endmodule
