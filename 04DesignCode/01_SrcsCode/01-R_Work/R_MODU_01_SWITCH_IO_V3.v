`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2023/09/09 12:42:06
// Design Name: 
// Module Name: SWITCH_IO_V3
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


module SWITCH_IO_V3(
  input CLK,
  input RESET_N,
  input [9:0] SW,
  input [9:0] SW_HISTORY,

  output wire [9:0] SW_HISTORY_OUT,

  output reg [1:0] SW_CHANGE_FLAG,
  output reg [3:0] WHICH_SW_CHANGE,

  output reg [7:0] UP_QUEUE,

  output reg [15:0] SEQUENCE,
  output reg [2:0] SEQUENCE_BIT
    );

  ////R：内部信号
	//R：循环计数器
  genvar i;
  //R：比较结果标志 Flag，注意此处，对于每一个 SW 的改变都做相应的记录
	//R：实际上是，10 × SW，每个 SW 需要用 [1:0] 进行表征 Up/Down/UnChange，一共 20 bit，解决“赋值”冲突
  reg [19:0] j;
	//R：扫描信号计数器，对于十个 SW 间隔时钟周期扫描，用于处理“时钟周期内多次操作”冲突的问题
	reg [3:0] k;

  parameter HalfByte = 4;
	parameter Mod_10 = 10;
  //R：对应各种情况，default 的情况包含 UnChange 和其他未知干扰
	parameter UnChange = 2;
  parameter Up = 1;
  parameter Down = 0; 

/*
	//R：第一个 always 块，用于电平信号的检出
	always @ (posedge CLK or negedge RESET_N)
	begin
		if(!RESET_N)   //R：系统 同步 RESET_N 的含义，将内部的数据全部置为初始态
			begin
				//R：对于内部信号，在收到同步复位也需要进行复位
				i <= 4'b0;
				j <= 20'b0;
			end
		else
			begin
				for ( i = 0; i < 10 ; i = i + 1)
					begin
						if (SW[i] > SW_HISTORY[i]) 
						j[(i * HalfByte/2) +: HalfByte/2] <= Up;
						else if (SW[i] < SW_HISTORY[i]) 
						j[(i * HalfByte/2) +: HalfByte/2] <= Down;
						else 
						j[(i * HalfByte/2) +: HalfByte/2] <= UnChange;
					end
			end
	end
*/
  generate for ( i = 0; i < 10 ; i = i + 1)
  begin:SWITCH_IO_V3_Generate_Block_1
    always @ (posedge CLK or negedge RESET_N)
    //R：第一个 always 块，用于电平信号的检出，其中 always 过程块只能写在 generate 块内部
    begin
      if(!RESET_N)   
      //R：系统 同步 RESET_N 的含义，将内部的数据全部置为初始态
        begin
          //R：对于内部信号，在收到同步复位也需要进行复位
          j <= 20'b0;
        end
      else
        begin
          if (SW[i] > SW_HISTORY[i]) 
          j[(i * HalfByte/2) +: HalfByte/2] <= Up;
          else if (SW[i] < SW_HISTORY[i]) 
          j[(i * HalfByte/2) +: HalfByte/2] <= Down;
          else 
          j[(i * HalfByte/2) +: HalfByte/2] <= UnChange;
        end
    end
  end
  endgenerate

	//R：第二个 always 块，将所有的电平变化检出后，开始按时间进行扫描，兼有数据译码 & 冲突处理
	always @ (posedge CLK or negedge RESET_N) 
	begin
		if(!RESET_N)    
		//R：注意，在扫描中，RESET_N 信号的含义，是从头开始扫描。
			begin         
				//R：注意，两个 always 块并行，第一个块中 在RESET_N 处理过的信号此处不需要重复处理
				//SW_CHANGE_FLAG <= { 0 , 0 }，Warning: Concatenation with unsized literal; will interpret as 32 bits
        SW_CHANGE_FLAG[0] <= 1'b0;
        SW_CHANGE_FLAG[1] <= 1'b0;
				WHICH_SW_CHANGE <= 4'hf;
				//R：硬件状态记录保持不变，这样同步 RESET_N 之后利用 硬件状态 实施的 冲突/矛盾处理 才是有效的
				UP_QUEUE <= UP_QUEUE;

				//R：注意 SEQUENCE 的复位并不存在于密码的总集中 4'd（0000~9999），由于只有四位总线，取这一个特殊值也是可以的
				SEQUENCE <= 16'hffff; 
				SEQUENCE_BIT <= 3'b0;
				
				k <= 4'b0;
			end
		else
			begin     //R：每次时钟触发一次计数，mod 10，从而 k 的取值范围 [0~9]，可以不断重复扫描
				case (j[(k * HalfByte/2) +: HalfByte/2])
					"Up": 
						begin
							//R：更新对于外部状态的单次直接描述，改变，且 Up。而 UP_QUEUE 是对外部硬件状态的整体直接描述
							//R：外部状态的单次直接描述，有改变就需要更新，不需要像其他过程量信号进行自检根据结果更新
							//R：所以，有改变，单次直接描述就要相应改变，而整体描述未必
							//SW_CHANGE_FLAG <= { Up , 1 };
              SW_CHANGE_FLAG[0] <= 1'b1;
              SW_CHANGE_FLAG[1] <= 1'b1;
							WHICH_SW_CHANGE <= k;

							if(UP_QUEUE[3:0] == 4'd0) 
							//R：Up 的 SW 数量 == 0，已经初始化做好了接收新 Up 的准备
                begin 
									//R:处理外部硬件状态，i.e.，UP_QUEUE，SW_CHANGE_FLAG，WHICH_SW_CHANGE
									//R:接收新的 Up
									UP_QUEUE[7:4] <= i; 
									//R: Up 队列入队计数++
									UP_QUEUE[3:0] <= UP_QUEUE[3:0] + 1;

									//R：外部硬件状态更新完之后，才是内部 SEQUENCE_BIT 自检
                  if(0 <= SEQUENCE_BIT < 4)//R：已初始化 && 正常输入状态 == 可以录入
                    begin
                      //R：更新内部信号状态，i.e.，实现 I/O
											//R：进一位，准备录入
                      SEQUENCE_BIT <= SEQUENCE_BIT + 1;
											//R：按照 i 的情况按位录入相应的密码
                      SEQUENCE[(SEQUENCE_BIT * HalfByte - 1) -:HalfByte] <= UP_QUEUE[7:4];
                    end
                  else//R：已初始化 && 超出输入位数（小于0 / 大于等于4） == 硬件有改变 但不能录入
                    begin
                      //R：外部硬件状态仍需要处理，只不过内部信号不做相应的更新
											//R:接收新的 Up，注意！接收不接收 Up 是由 UP_QUEUE[3:0] 决定
                      //UP_QUEUE[7:4] <= i;
											//R: Up 队列入队计数++
                      //UP_QUEUE[3:0] <= UP_QUEUE[3:0] + 1;
                      //R：不更新内部 I/O
                      SEQUENCE_BIT <= SEQUENCE_BIT;
                      SEQUENCE <= SEQUENCE;
                    end
                end
							else    
							//R：此前已经有 Up 的 SW，根本不用 SEQUENCE_BIT 自检，直接锁死内部 I/O
							//R：但外部硬件状态还是需要记录的
								begin
									UP_QUEUE[7:4] <= UP_QUEUE[7:4];//R:不接收新的 Up 
									UP_QUEUE[3:0] <= UP_QUEUE[3:0] + 1;//R: 但仍要更新 Up 入队计数
									//R：不更新内部 I/O
									SEQUENCE_BIT <= SEQUENCE_BIT;
									SEQUENCE <= SEQUENCE;
								end
						end
					"Down":
						begin
							//R：单次状态描述，必须改变
							//SW_CHANGE_FLAG <= { Down , 1 };
              SW_CHANGE_FLAG[0] <= 1'b1;
              SW_CHANGE_FLAG[1] <= 1'b0;
							WHICH_SW_CHANGE <= k;

							//R：UP_QUEUE，根据情况相应改变
              if((UP_QUEUE[3:0] == 4'd0) || (UP_QUEUE[3:0] == 4'd1))
                begin
                  UP_QUEUE[3:0] <= 4'd0;
                  UP_QUEUE[7:4] <= 4'hF;
                end
              else
                begin
                  UP_QUEUE[3:0] <= UP_QUEUE[3:0] - 1;
                  UP_QUEUE[7:4] <= UP_QUEUE[7:4];
                end

							//R：内部译码不变
							SEQUENCE_BIT <= SEQUENCE_BIT;
              SEQUENCE <= SEQUENCE;
						end
					default://R：某个 SW 不变的情况，外部硬件状态 & 内部 I/O 都不做改变
            begin
							//R：注意，单次状态描述，Flag[1] = 0 , WHICH_SW_CHANGE <= 4'hf，都是特殊含义复用，实际检测中要配合使用
							//SW_CHANGE_FLAG <= { 0 , 0 };
              SW_CHANGE_FLAG[0] <= 1'b0;
              SW_CHANGE_FLAG[1] <= 1'b0;
							WHICH_SW_CHANGE <= 4'hf;
              UP_QUEUE <= UP_QUEUE;
              SEQUENCE_BIT <= SEQUENCE_BIT;
              SEQUENCE <= SEQUENCE;
            end 
				endcase
				//R：切换到下一位进行扫描，所以进入 case 匹配的 k，就是当前正要扫描处理的 bit
				k <= (k + 1) % Mod_10;
			end
	end

  //R：此 assign 与上面的 always 并行，实际上只是避免修改 input SW，所以单独设置信号将其引出
  assign SW_HISTORY_OUT = SW;
endmodule
