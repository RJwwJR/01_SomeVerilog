`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2023/09/07 22:16:11
// Design Name: 
// Module Name: R_MODU_02_BTN_IO
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


module BTN_IO(
  //R：系统 ns 时钟，在译码时更及时
  input CLK,
  //R：注意，是 BTN 电平处理之后生成的系统内部同步复位信号，不是直接的 BTN 电平
  input RESET,
  //R：实际的电平信号，对应关系见下面的 parameter 定义
  input [3:0] BTN,
  
  //R：1'b二进制信号，用于描述 BTN[1:0] 的整体改变情况
  output reg BTN_CHANGE_FLAG,
  //R：取值范围 0/1/2/3 ，用总线的值，取为十进制形式，用两位总线恰好容纳
  output reg [1:0] WHICH_BTN_POSEDGE
  );
//……………………………………………………………………………………………………………………………………………………………………………………………………………………………………………………………………………
  ////R：参数定义
  parameter Mod_4 = 4;
  //R：方便 BTN 总线按下标索引相应按钮电平的书写
  //R：对应关系———— BTN_RESET——BTN[0]，BTN_ADMIN——BTN[1]，BTN_OK——BTN[2]，BTN_BACKSPACE——BTN[3]
  parameter BTN_RESET = 0;
  parameter BTN_ADMIN = 1;
  parameter BTN_OK = 2;
  parameter BTN_BACKSPACE = 3;
//……………………………………………………………………………………………………………………………………………………………………………………………………………………………………………………………………………
  ////R：内部信号
  wire Temp_Clk_wire;
  reg Temp_Clk_reg;
  wire [3:0] Btn_Posedge_wireBus;
  reg [3:0] Btn_Posedge_regBus;
  //R：循环计数器
  genvar  i;
  //R：扫描计数器，对于 4个 BTN 电平，只要设置 2 bit + mod 4 即可，设置 3 bit 为保险
  reg [2:0] j;

//……………………………………………………………………………………………………………………………………………………………………………………………………………………………………………………………………………

	////R：仿照 SW 的风格，本应该有第一个 always 块用于电平的检测，但在 BTN 上实际是通过调用各模块来实现，所以不存在第一个 always 块
	////R：实例化时钟、消抖模块
	//R：先实例化时钟
	M_CLK M_CLK_inst(
		.Clk_in(CLK),
		.Reset(RESET),
		.Clk_Out(Temp_Clk_wire));
	//R：利用中间导线导出时钟，转换成 reg 的主要目的是存储之后再利用
	//R：组合逻辑，用阻塞赋值，但由于 Temp_Clk_wire 是按某时钟周期做改变，实际上 Temp_Clk_reg 也有一定的周期进行改变
	always @ (Temp_Clk_wire)
	Temp_Clk_reg = Temp_Clk_wire;

//……………………………………………………………………………………………………………………………………………………………

	////R：对四个 BTN 分别用消抖提取上升沿信息
	//R：BTN_RESET == 0 的提取，只要用for循环即可
  generate for(i = 0 ; i < 4 ; i = i + 1)
    begin:BTN_IO_Generate_Block_1
      BTN_JITTER  BTN_JITTER_inst(
      .CLK(Temp_Clk_reg),
      .BTN_IN(BTN[i]),
      .BTN_POSEDGE(Btn_Posedge_wireBus[i]));
    //R：再次利用中间导线，引出 Btn_Posedge_regBus 外部硬件状态的描述
		//R：对于时序逻辑，认为不出现用电平作为敏感信号的直接赋值比较合适
      //always @ (Btn_Posedge_wireBus[i])
			always @ (posedge CLK)
      Btn_Posedge_regBus[i] <= Btn_Posedge_wireBus[i];
    end
  endgenerate
//……………………………………………………………………………………………………………………………………………………………

	//R：所有的提取结束， Btn_Posedge_regBus 记录了所有的上升沿信息，第二个 always 块进行 电平-数据译码
	//R：不同于 SW，BTN 的检测/提取单独分出 消抖模块，剩下的只需要在每个时钟上升沿进行检测即可，依然采用扫描的处理方式
	always @ (posedge CLK or posedge RESET)
	begin
		if(RESET)
			begin
				BTN_CHANGE_FLAG <= 0;
				WHICH_BTN_POSEDGE <= 2'b0;

				Btn_Posedge_regBus <= 2'b0;
				//R：对于 wire 类型信号，由于每次只是作为连接线，被其他源驱动，所以无所谓是否复位
				//R：对于计数器 i，在每次 for循环起始就会被初始化，所以也不需要考虑复位的情况
			end
		else
			begin
				if( Btn_Posedge_regBus[j] )    //R：扫描到的当前位恰为上升沿 ——→ 检出上升沿，译码更新
				begin
					BTN_CHANGE_FLAG <= 1;
					WHICH_BTN_POSEDGE <= j;
				end
				else                           //R：扫描到的不变 ——→ 未检出上升沿，清空
				begin
					//R：注意，此处与 SW 的情况不同，对于 SW 是电平量（过程量），此处 BTN 为边沿量（瞬时量），所以没有改变的处理为置零而非保持原值
					BTN_CHANGE_FLAG <= 0;
					//R：注意，WHICH_BTN_POSEDGE 被置零其实是 BTN_RESET，所以实际检测时必须和 BTN_CHANGE_FLAG 结合才能使用
					WHICH_BTN_POSEDGE <= 0;
				end
				//R：扫描计数器 mod 4 向前扫描
				j <= (j + 1) % Mod_4;
			end
	end

		
endmodule
