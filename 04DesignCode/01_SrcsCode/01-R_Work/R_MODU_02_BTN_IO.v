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
  //R��ϵͳ ns ʱ�ӣ�������ʱ����ʱ
  input CLK,
  //R��ע�⣬�� BTN ��ƽ����֮�����ɵ�ϵͳ�ڲ�ͬ����λ�źţ�����ֱ�ӵ� BTN ��ƽ
  input RESET_N,
  //R��ʵ�ʵĵ�ƽ�źţ���Ӧ��ϵ������� parameter ����
  input [3:0] BTN,
  
  //R��1'b�������źţ��������� BTN[1:0] ������ı����
  output reg BTN_Change_Flag,
  //R���±귶Χ 0/1/2/3 ��ȡΪʮ������ʽ������λ����ǡ������
  output reg [1:0] Which_BTN_Posedge);

  ////R����������
	parameter Mod_4 = 4;
  //R��Which_BTN_Posedge �� 4 �������0/1/2/3��ʮ���Ʊ�ʾ
  //R����Ӧ��ϵ�������� BTN_RESET����BTN[0]��BTN_ADMIN����BTN[1]��BTN_OK����BTN[2]��BTN_BACKSPACE����BTN[3]
  parameter BTN_RESET = 0;
  parameter BTN_ADMIN = 1;
  parameter BTN_OK = 2;
  parameter BTN_BACKSPACE = 3;

  ////R���ڲ��ź�
  wire Temp_Clk_wire;
  reg Temp_Clk_reg;
	wire [3:0] Btn_Posedge_wireBus;
	reg [3:0] Btn_Posedge_regBus;
	//R��ѭ��������
	reg [1:0] i;
	//R��ɨ������������� 4�� BTN ��ƽ��ֻҪ���� 2 bit + mod 4 ���ɣ����� 3 bit Ϊ����
	reg [2:0] j;


	//R������ SW �ķ�񣬵�һ�� always �����ڵ�ƽ�ļ�⣨�� BTN ��ʵ����ͨ�����ø�ģ����ʵ��
	always @ (posedge CLK or negedge RESET_N)
	begin
		if(!RESET_N)    //R������ֻ�漰 BTN ��ƽ�ļ�⣬����ֻ���ͱ����йصı�����λ
			begin
				Temp_Clk_reg <= 0;
				Btn_Posedge_regBus <= 2'b0;
				//R������ wire �����źţ�����ÿ��ֻ����Ϊ�����ߣ�������Դ��������������ν�Ƿ�λ
				//R�����ڼ����� i����ÿ�� forѭ����ʼ�ͻᱻ��ʼ��������Ҳ����Ҫ���Ǹ�λ�����
			end
		else
			begin
				////R��ʵ����ʱ�ӡ�����ģ��
				//R����ʵ����ʱ��
				M_CLK M_CLK_inst(
					.Clk_in(CLK),
					.Reset_N(RESET),
					.Clk_Out(Temp_Clk_wire)
				);
				//R�������м䵼�ߵ���ʱ�ӣ�ת���� reg ����ҪĿ���Ǵ洢֮��������
				Temp_Clk_reg <= Temp_Clk_wire;

				////R�����ĸ� BTN �ֱ���������ȡ��������Ϣ
				//R��BTN_RESET == 0 ����ȡ��ֻҪ��forѭ������
				for(i = 0 ; i < 4 ; i = i + 1)
				begin
					BTN_JITTER  BTN_JITTER_RESET(
					.CLK(Temp_Clk_reg),
					.BTN_IN(BTN[i]),
					.BTN_POSEDGE(Btn_Posedge_wireBus[i])
				);
				//R���ٴ������м䵼�ߣ����� Btn_Posedge_regBus �ⲿӲ��״̬������
				Btn_Posedge_regBus[i] <= Btn_Posedge_wireBus[i];
				end
			end
	end

	//R�����е���ȡ������ Btn_Posedge_regBus ��¼�����е���������Ϣ���ڶ��� always ����� ��ƽ-��������
	//R����ͬ�� SW��BTN �ļ��/��ȡ�����ֳ� ����ģ�飬ʣ�µ�ֻ��Ҫ��ÿ��ʱ�������ؽ��м�⼴�ɣ���Ȼ����ɨ��Ĵ���ʽ
	always @ (posedge CLK or negedge RESET_N)
	begin
		if(! RESET_N)
			begin
				//R�����¿�ʼɨ��
				j <= 3'b0;
				BTN_Change_Flag <= 0;
				Which_BTN_Posedge <= 2'b0;
			end
		else
			begin
				if( Btn_Posedge_regBus[j] )    //R��ɨ�赽�ĵ�ǰλǡΪ������ ������ ��������أ��������
				begin
					BTN_Change_Flag <= 1;
					Which_BTN_Posedge <= j;
				end
				else                           //R��ɨ�赽�Ĳ��� ������ δ��������أ����
				begin
					//R��ע�⣬�˴��� SW �������ͬ������ SW �ǵ�ƽ���������������˴� BTN Ϊ��������˲ʱ����������û�иı�Ĵ���Ϊ������Ǳ���ԭֵ
					BTN_Change_Flag <= 0;
					//R��ע�⣬Which_BTN_Posedge ��������ʵ�� BTN_RESET������ʵ�ʼ��ʱ����� BTN_Change_Flag ��ϲ���ʹ��
					Which_BTN_Posedge <= 0;
				end
				//R��ɨ������� mod 4 ��ǰɨ��
				j <= (j + 1) % Mod_4;
			end
	end

		
endmodule
