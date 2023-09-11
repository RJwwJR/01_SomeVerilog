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

//……………………………………………………………………………………………………………………………………………………………………………………………………………………………………………………………………………
  ////R：参数定义
  //R：有 4 种情况，0/1/2/3，十进制表示
  //R：对应关系———— BTN_RESET——BTN[0]，BTN_ADMIN——BTN[1]，BTN_OK——BTN[2]，BTN_BACKSPACE——BTN[3]
  parameter BTN_RESET = 0;
  parameter BTN_ADMIN = 1;
  parameter BTN_OK = 2;
  parameter BTN_BACKSPACE = 3;
  //R：常用常量
  parameter Mod_10 = 10;
  //R：状态声明
  parameter WAIT = 3'd0;
  parameter INPUT = 3'd1;
  parameter ERROR = 3'd2;
  parameter ALARM = 3'd3;
  parameter UNLOCK = 3'd4;

//……………………………………………………………………………………………………………………………………………………………………………………………………………………………………………………………………………
  ////R：内部信号
  //R：状态寄存
  reg [2:0] Current_State;
  reg [2:0] Next_State;
//…………………………………………………………………………………………………………………………………………………………………………………………………………………
  ////R：为处理 SW 电平信号，设置的外部硬件译码信号
  //R：用 0/1 Flag 表征 SW 电平信号是否改变，0——不变，1——改变
  //reg Code_Change_Flag;//R：不足够，因为对于冲突的处理，需要明确知道具体哪个 SW 发生了 UP/DOWN 怎样的变化
  //R：用更为细致的方式进行表述，为了判断具体哪个 SW 发生了怎样的变化，需要记录历史 电平 情况进行比较
  //R：为了在比较后将 SW_History 进行更新，在 input/output 中各放一个 History 的变量，方便块执行后更新
  reg [9:0] SW_History;
  //R：两位 bus，[0]————是否改变的 Flag，0——No，1——Yes
  //R：[1]————Up/Down 的 Flag
  wire [1:0] SW_Change_Flag;
  //R：有用的是总线值的大小，4'd[0~9]
  wire [3:0] Which_SW_Change;
  //R：[7:4]————第一个 Up，[3:0]————有几个 Up
  wire [7:0] Up_Queue;
//…………………………………………………………………………………………………………………………………………………………………………………………………………………
  //R：读取 SW 电平信号后存储在内部的 Code & Key，真正的内部信号
  reg [15:0] Key;
  reg [2:0] Key_Bit;
  reg [15:0] Code;
  //R：记录已经输入的 Code bit，具有的取值范围————0,1,2,3,4，所以需要三位总线
  reg [2:0] Code_Bit;
  //R：辅助处理 SW 的生成信号，作为两次延时的中转
  reg [9:0] SW_History_Mid;
  //R：用于同步 主控模块 & SW_IO 模块的扫描信号
  reg [3:0] Scan_Counter;
  wire [19:0] SW_Difference;
//…………………………………………………………………………………………………………………………………………………………………………………………………………………
  ///R：为处理 BTN 电平信号，设置的一组外部硬件译码信号信号
  //R：用 0/1 Flag 表征 BTN 电平信号是否改变，0——不变，1——改变
  wire BTN_Change_Flag;
  //R：用 Which 表征具体哪一个 BTN 上升沿被触发，注意 RESET 已经被分立出去
  wire [1:0] Which_BTN_Posedge;
//…………………………………………………………………………………………………………………………………………………………………………………………………………………
  //R：读取 BTN 电平上升沿后，真正的内部信号
  reg [3:0] Signal_BTN;
//…………………………………………………………………………………………………………………………………………………………………………………………………………………
  ///R：用于辅助处理的内部信号
  //R：用于区分 ADMIN/USER 权限，ADMIN = 1，默认复位成 USER = 0
  reg Id_Flag;
  //R：系统是否开锁，不单独设置状态
  reg Lock_Flag;
  //R：十进制信号，用于错误次数的统计，可以有 1/2/3 三种取值情况
  reg [1:0] Error_Time;

//……………………………………………………………………………………………………………………………………………………………………………………………………………………………………………………………………………
  //R：将 BTN 的电平检测模块实例化
  BTN_IO BTN_IO_inst(
    .CLK(CLK),
    .RESET(Signal_BTN[BTN_RESET]),
    .BTN(BTN),
//………………………………………………………………………………………………………
    .BTN_CHANGE_FLAG(BTN_Change_Flag),
    .WHICH_BTN_POSEDGE(Which_BTN_Posedge)
  );
//…………………………………………………………………………………………………………………………………………………
  //R：根据 BTN 的上升沿扫描情况，译码到内部信号 "Signal_BTN = 哪个按钮被按下"，没有则置空
  //R：敏感信号必须是 CLK，这样在没有按钮被按下时才会把 Signal_BTN 自动初始化
  always @ (posedge CLK)
  begin
    if(BTN_Change_Flag)
    begin
      Signal_BTN <= 4'b0;
      case (Which_BTN_Posedge)
        "BTN_RESET":     Signal_BTN[BTN_RESET] <= 1;
        "BTN_ADMIN":     Signal_BTN[BTN_ADMIN] <= 1;
        "BTN_OK":        Signal_BTN[BTN_OK] <= 1;
        "BTN_BACKSPACE": Signal_BTN[BTN_BACKSPACE] <= 1;
        //R：出现干扰则 复位
        default:         Signal_BTN <= 4'b0;
      endcase
    end
    else                 Signal_BTN <= 4'b0;
  end

//…………………………………………………………………………………………………………………………………………………………………………………………………………………
  //R：将 SWITCH 的电平检测模块实例化
  SWITCH_IO_V4 SWITCH_IO_V4_inst(
    .CLK(CLK),
    .RESET(Signal_BTN[BTN_RESET]),
    .SW(SW),
    .SW_HISTORY(SW_History),
    .SCAN_COUNTER(Scan_Counter),
//………………………………………………………………………………………………………
    .SW_CHANGE_FLAG(SW_Change_Flag),
    .WHICH_SW_CHANGE(Which_SW_Change),
    .UP_QUEUE(Up_Queue),
//………………………………………………………………………………………………………
    .SW_DIFFERENCE(SW_Difference)
  );
//…………………………………………………………………………………………………………………………………………………
  //R：产生扫描信号
  always @ (posedge CLK)
  Scan_Counter <= (Scan_Counter + 1) % Mod_10;
//…………………………………………………………………………………………………………………………………………………
  //R：延时两次产生 SW_History 信号
  always @ (posedge CLK) 
  SW_History_Mid <= SW;
  always @ (posedge CLK)
  SW_History <= SW_History_Mid;
//…………………………………………………………………………………………………………………………………………………
  //R：根据 Curren_State、Id_Flag、Bit ……对 SWITCH 电平进行译码处理
  
  always @ (posedge CLK) 
  begin
    if((Current_State != WAIT) && (Current_State != INPUT))
    //R：在其他状态，不需要输入密码，因而不进行译码，电平要保持
    //R：电平保持为，方便之后显示不译码过程中积累的情况
    begin
      
    end
    else
    //R：Current_State 符合译码条件，进一步根据变化标志位判断是否需要译码
      if (BTN_Change_Flag) begin
      //R：如果有 BTN 的变化，先对 BTN 的变化进行处理
      //R：人为指定 BTN 的优先级高于 SW

        
      end else begin
        
      end
  end


//…………………………………………………………………………………………………………………………………………………………………………………………………………………
  //R:状态寄存 & 转换逻辑
  always @ (posedge CLK or posedge Signal_BTN[BTN_RESET])
  begin
  if(Signal_BTN[BTN_RESET])
    Current_State <= WAIT;
  else
    Current_State <= Next_State;
  end

//…………………………………………………………………………………………………………………………………………………………………………………………………………………
  //R：次态逻辑,复位已经在状态寄存中写掉，此处已经无需再考虑
  always @ (Current_State or SW_Change_Flag[0] or BTN_Change_Flag)
  begin
    case(Current_State)
      "WAIT":
      begin
        if(SW_Change_Flag[0] || Signal_BTN[BTN_ADMIN])
          Next_State = INPUT;
        else
          Next_State = WAIT;
      end
      "INPUT":
      begin
        if (SW_Change_Flag[0] || Signal_BTN[BTN_ADMIN] || Signal_BTN[BTN_BACKSPACE]) 
          Next_State = INPUT;
        else if(Signal_BTN[BTN_OK])
        begin
          if(Id_Flag)
          //R：Id_Flag == 1.管理员权限
          begin
            if(Key_Bit == 4)
            //R：新的密码设置完成，回到等待状态
              Next_State = WAIT;
            else
            //R：密码未输全，回到 Bit = 0 的状态重新输入
              Next_State = INPUT;
          end
          else
          //R：Id_Flag == 0，非管理员权限,
          begin
            if(Key_Bit == 4)
            //R：密码位数正确，再检查是否匹配
              if(Code == Key)
              //R：匹配，解锁
                Next_State = UNLOCK;
              else
              //R：不匹配，错误次数++，并相应检测 ERROR/ALARM
              begin
                Error_Time = Error_Time + 1;
                if(Error_Time == 3)
                  Next_State = ALARM;
                else
                  Next_State = ERROR;
              end
            else
            //R：密码位数不正确，错误次数增加，并根据错误次数再分支
            begin
              Error_Time = Error_Time + 1;
              if(Error_Time == 3)
                Next_State = ALARM;
              else
                Next_State = ERROR;
            end
          end
        end
        else
        //R：剩下情况，正常只有按下 BTN_RESET 时，剩下异常情况复位 WAIT 一并处理 
          Next_State = WAIT;
      end
      "ERROR":
      begin
        if(SW_Change_Flag[0]
          || Signal_BTN[BTN_BACKSPACE] || Signal_BTN[BTN_OK])
        //R：SW/某些按键变化,单纯回到 INPUT，保留错误密码（不是清零重新输入
        begin
          Error_Time = Error_Time;
          Next_State = INPUT;
        end
        else
        //R：有管理员权限/reset，认为错误次数直接清空，回到上锁状态
        begin
          Error_Time = 0;
          Next_State = WAIT;
        end
      end
      "ALARM":
      begin
        if(Signal_BTN[BTN_OK] || Signal_BTN[BTN_BACKSPACE]
          || SW_Change_Flag[0])
        //R：不会起效，继续报警
        begin
          Error_Time = Error_Time;
          Next_State = ALARM;
        end
        else
        //R：管理员制止报警/复位/扰动，重新回到等待上锁
        begin
          Error_Time = 0;
          Next_State = WAIT;
        end
      end
      "UNLOCK":
      begin
        //R：解锁后，先前的错误次数一定清空
        Error_Time = 0;
        if(Signal_BTN[BTN_ADMIN] || Signal_BTN[BTN_RESET])
        //R：复位的情况
         Next_State = WAIT;
        else
        //R：解锁后其他的操作可以任意进行
          Next_State = UNLOCK;
      end
      default:
        Next_State = WAIT;
    endcase
  end
endmodule
