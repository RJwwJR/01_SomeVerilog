`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2023/09/08 16:38:58
// Design Name: 
// Module Name: R_MODU_01_SWITCH_IO_V2
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


module R_MODU_01_SWITCH_IO_V2(
	input CLK,
	input RESET_N,
	input [9:0] SW,
	input [9:0] SW_History,

	output reg [7:0] Up_Queue,
	output wire [9:0] SW_History_Out,
	output reg [15:0] Code,
	output reg [2:0] Code_Bit
	);

	////R：内部信号
	//R：循环计数器
  reg [3:0] i;
  //R：比较结果标志 Flag，注意此处，对于每一个 SW 的改变都做相应的记录
	//R：实际上是，10 × SW，每个 SW 需要用 [1:0] 进行表征，一共 20 bit
  reg [19:0] j;
	//R：扫描信号计数器，对于十个 SW 间隔时钟周期扫描，用于处理冲突的问题
	reg [3:0] k;

  parameter Byte = 4;
	parameter Mod = 10;
  //R：对应 j 的各种情况，default 的情况包含 Down 和其他未知干扰
  parameter Up = 1;
  parameter Down = 0; 

	//R：第一个 always 块，用于电平信号的检出
	always @ (posedge CLK or negedge RESET_N)
	begin
		if(!RESET_N)   //R：系统 同步 RESET_N 的含义，将内部的数据全部置为初始态
			begin
				//R：硬件状态记录保持不变，这样同步 RESET_N 之后利用 硬件状态 实施的 冲突/矛盾处理 才是有效的
				Up_Queue <= Up_Queue;
				//R：注意 Code 的初始态并不存在于密码的总集中，由于只有四位总线，取这一个特殊值也是可以的
				Code <= 16'hffff; 
				Code_Bit <= 3'b0;
				//R：对于内部信号，在收到同步复位也需要进行复位
				i <= 4'b0;
				j <= 20'b0;
			end
		else
			begin
				for ( i = 0; i <= 9 ; i = i + 1)
					begin
						if (SW[i] > SW_History[i]) 
						j[(i * Byte/2) +: Byte/2] <= 1;
						else if (SW[i] < SW_History[i]) 
						j[(i * Byte/2) +: Byte/2] <= 0;
						else 
						j[(i * Byte/2) +: Byte/2] <= 2;
					end
			end
	end

	//R：第二个 always 块，将所有的电平变化检出后，开始按时间进行扫描，兼容数据译码 & 冲突处理
	always @ (posedge CLK or negedge RESET_N) 
	begin
		if(!RESET_N)    //R：注意在扫描中，RESET_N 信号的含义，是从头开始扫描。
			begin         //R：注意两个 always 块并行，第一个块中 在RESET_N 处理过的信号此处不需要重复处理，那么只需要处理扫描计数器
				k <= 4'b0;
			end
		else
			begin     //R：每次时钟触发一次计数，mod 10，从而 k 的取值范围 [0~9]，可以不断重复扫描
				case (j[(k * Byte/2) +: Byte/2])
					"Up": 
						begin
							if(Up_Queue[3:0] == 4'd0) //R：Up 的 SW 数量 == 0，已经初始化做好了接收新 Up 的准备
                begin 
                  if(0 <= Code_Bit < 4)//R：已初始化 && 正常输入状态 == 可以录入
                    begin
                      //R:处理外部硬件状态，i.e.，Up_Queue
											//R:接收新的 Up
                      Up_Queue[7:4] <= i; 
											//R: Up 队列入队计数++
                      Up_Queue[3:0] <= Up_Queue[3:0] + 1;
                      //R：更新内部信号状态，i.e.，实现 I/O
											//R：进一位，准备录入
                      Code_Bit <= Code_Bit + 1;
											//R：按照 i 的情况按位录入相应的密码
                      Code[(Code_Bit * Byte - 1) -:Byte] <= Up_Queue[7:4];
                    end
                  else//R：已初始化 && 超出输入位数（小于0 / 大于等于4） == 硬件有改变 但不能录入
                    begin
                      //R：外部硬件状态仍需要处理，只不过内部信号不做相应的更新
											//R:接收新的 Up，注意！接收不接收 Up 是由 Up_Queue[3:0] 决定
                      Up_Queue[7:4] <= i;
											//R: Up 队列入队计数++
                      Up_Queue[3:0] <= Up_Queue[3:0] + 1;
                      //R：不更新内部 I/O
                      Code_Bit <= Code_Bit;
                      Code <= Code;
                    end
                end
							else    //R：此前已经有 Up 的 SW，根本不用 Code_Bit 自检，直接锁死内部 I/O
								      //R：但外部硬件状态还是需要记录的
								begin
									Up_Queue[7:4] <= Up_Queue[7:4];//R:不接收新的 Up 
									Up_Queue[3:0] <= Up_Queue[3:0] + 1;//R: 但仍要更新 Up 入队计数
									//R：不更新内部 I/O
									Code_Bit <= Code_Bit;
									Code <= Code;
								end
						end
					"Down":
						begin
							Code_Bit <= Code_Bit;
              Code <= Code;
              if((Up_Queue[3:0] == 4'd0) || (Up_Queue[3:0] == 4'd1))
                begin
                  Up_Queue[3:0] <= 4'd0;
                  Up_Queue[7:4] <= 4'hF;
                end
              else
                begin
                  Up_Queue[3:0] <= Up_Queue[3:0] - 1;
                  Up_Queue[7:4] <= Up_Queue[7:4];
                end
						end
					default://R：某个 SW 不变的情况，外部硬件状态 & 内部 I/O 都不做改变
            begin
              Up_Queue <= Up_Queue;
              Code_Bit <= Code_Bit;
              Code <= Code;
            end 
				endcase
				//R：切换到下一位进行扫描，所以进入 case 匹配的 k，就是当前正要扫描处理的 bit
				k <= (k + 1) % Mod;
			end
	end

  //R：此 assign 与上面的 always 并行，实际上只是避免修改 input SW，所以单独设置信号将其引出
  assign SW_History_Out = SW;
endmodule
