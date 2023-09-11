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
  input RESET,
  //R��ʵ�ʵĵ�ƽ�źţ���Ӧ��ϵ������� parameter ����
  input [3:0] BTN,
  
  //R��1'b�������źţ��������� BTN[1:0] ������ı����
  output reg BTN_CHANGE_FLAG,
  //R��ȡֵ��Χ 0/1/2/3 �������ߵ�ֵ��ȡΪʮ������ʽ������λ����ǡ������
  output reg [1:0] WHICH_BTN_POSEDGE
  );
//����������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������
  ////R����������
  parameter Mod_4 = 4;
  //R������ BTN ���߰��±�������Ӧ��ť��ƽ����д
  //R����Ӧ��ϵ�������� BTN_RESET����BTN[0]��BTN_ADMIN����BTN[1]��BTN_OK����BTN[2]��BTN_BACKSPACE����BTN[3]
  parameter BTN_RESET = 0;
  parameter BTN_ADMIN = 1;
  parameter BTN_OK = 2;
  parameter BTN_BACKSPACE = 3;
//����������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������
  ////R���ڲ��ź�
  wire Temp_Clk_wire;
  reg Temp_Clk_reg;
  wire [3:0] Btn_Posedge_wireBus;
  reg [3:0] Btn_Posedge_regBus;
  //R��ѭ��������
  genvar  i;
  //R��ɨ������������� 4�� BTN ��ƽ��ֻҪ���� 2 bit + mod 4 ���ɣ����� 3 bit Ϊ����
  reg [2:0] j;

//����������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������

	////R������ SW �ķ�񣬱�Ӧ���е�һ�� always �����ڵ�ƽ�ļ�⣬���� BTN ��ʵ����ͨ�����ø�ģ����ʵ�֣����Բ����ڵ�һ�� always ��
	////R��ʵ����ʱ�ӡ�����ģ��
	//R����ʵ����ʱ��
	M_CLK M_CLK_inst(
		.Clk_in(CLK),
		.Reset(RESET),
		.Clk_Out(Temp_Clk_wire));
	//R�������м䵼�ߵ���ʱ�ӣ�ת���� reg ����ҪĿ���Ǵ洢֮��������
	//R������߼�����������ֵ�������� Temp_Clk_wire �ǰ�ĳʱ���������ı䣬ʵ���� Temp_Clk_reg Ҳ��һ�������ڽ��иı�
	always @ (Temp_Clk_wire)
	Temp_Clk_reg = Temp_Clk_wire;

//����������������������������������������������������������������������������������������������������������������������

	////R�����ĸ� BTN �ֱ���������ȡ��������Ϣ
	//R��BTN_RESET == 0 ����ȡ��ֻҪ��forѭ������
  generate for(i = 0 ; i < 4 ; i = i + 1)
    begin:BTN_IO_Generate_Block_1
      BTN_JITTER  BTN_JITTER_inst(
      .CLK(Temp_Clk_reg),
      .BTN_IN(BTN[i]),
      .BTN_POSEDGE(Btn_Posedge_wireBus[i]));
    //R���ٴ������м䵼�ߣ����� Btn_Posedge_regBus �ⲿӲ��״̬������
		//R������ʱ���߼�����Ϊ�������õ�ƽ��Ϊ�����źŵ�ֱ�Ӹ�ֵ�ȽϺ���
      //always @ (Btn_Posedge_wireBus[i])
			always @ (posedge CLK)
      Btn_Posedge_regBus[i] <= Btn_Posedge_wireBus[i];
    end
  endgenerate
//����������������������������������������������������������������������������������������������������������������������

	//R�����е���ȡ������ Btn_Posedge_regBus ��¼�����е���������Ϣ���ڶ��� always ����� ��ƽ-��������
	//R����ͬ�� SW��BTN �ļ��/��ȡ�����ֳ� ����ģ�飬ʣ�µ�ֻ��Ҫ��ÿ��ʱ�������ؽ��м�⼴�ɣ���Ȼ����ɨ��Ĵ���ʽ
	always @ (posedge CLK or posedge RESET)
	begin
		if(RESET)
			begin
				BTN_CHANGE_FLAG <= 0;
				WHICH_BTN_POSEDGE <= 2'b0;

				Btn_Posedge_regBus <= 2'b0;
				//R������ wire �����źţ�����ÿ��ֻ����Ϊ�����ߣ�������Դ��������������ν�Ƿ�λ
				//R�����ڼ����� i����ÿ�� forѭ����ʼ�ͻᱻ��ʼ��������Ҳ����Ҫ���Ǹ�λ�����
			end
		else
			begin
				if( Btn_Posedge_regBus[j] )    //R��ɨ�赽�ĵ�ǰλǡΪ������ ������ ��������أ��������
				begin
					BTN_CHANGE_FLAG <= 1;
					WHICH_BTN_POSEDGE <= j;
				end
				else                           //R��ɨ�赽�Ĳ��� ������ δ��������أ����
				begin
					//R��ע�⣬�˴��� SW �������ͬ������ SW �ǵ�ƽ���������������˴� BTN Ϊ��������˲ʱ����������û�иı�Ĵ���Ϊ������Ǳ���ԭֵ
					BTN_CHANGE_FLAG <= 0;
					//R��ע�⣬WHICH_BTN_POSEDGE ��������ʵ�� BTN_RESET������ʵ�ʼ��ʱ����� BTN_CHANGE_FLAG ��ϲ���ʹ��
					WHICH_BTN_POSEDGE <= 0;
				end
				//R��ɨ������� mod 4 ��ǰɨ��
				j <= (j + 1) % Mod_4;
			end
	end

		
endmodule
