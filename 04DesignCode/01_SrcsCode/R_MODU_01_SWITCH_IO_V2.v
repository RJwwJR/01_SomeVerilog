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

	////R���ڲ��ź�
	//R��ѭ��������
  reg [3:0] i;
  //R���ȽϽ����־ Flag��ע��˴�������ÿһ�� SW �ĸı䶼����Ӧ�ļ�¼
	//R��ʵ�����ǣ�10 �� SW��ÿ�� SW ��Ҫ�� [1:0] ���б�����һ�� 20 bit
  reg [19:0] j;
	//R��ɨ���źż�����������ʮ�� SW ���ʱ������ɨ�裬���ڴ����ͻ������
	reg [3:0] k;

  parameter Byte = 4;
	parameter Mod = 10;
  //R����Ӧ j �ĸ��������default ��������� Down ������δ֪����
  parameter Up = 1;
  parameter Down = 0; 

	//R����һ�� always �飬���ڵ�ƽ�źŵļ��
	always @ (posedge CLK or negedge RESET_N)
	begin
		if(!RESET_N)   //R��ϵͳ ͬ�� RESET_N �ĺ��壬���ڲ�������ȫ����Ϊ��ʼ̬
			begin
				//R��Ӳ��״̬��¼���ֲ��䣬����ͬ�� RESET_N ֮������ Ӳ��״̬ ʵʩ�� ��ͻ/ì�ܴ��� ������Ч��
				Up_Queue <= Up_Queue;
				//R��ע�� Code �ĳ�ʼ̬����������������ܼ��У�����ֻ����λ���ߣ�ȡ��һ������ֵҲ�ǿ��Ե�
				Code <= 16'hffff; 
				Code_Bit <= 3'b0;
				//R�������ڲ��źţ����յ�ͬ����λҲ��Ҫ���и�λ
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

	//R���ڶ��� always �飬�����еĵ�ƽ�仯����󣬿�ʼ��ʱ�����ɨ�裬������������ & ��ͻ����
	always @ (posedge CLK or negedge RESET_N) 
	begin
		if(!RESET_N)    //R��ע����ɨ���У�RESET_N �źŵĺ��壬�Ǵ�ͷ��ʼɨ�衣
			begin         //R��ע������ always �鲢�У���һ������ ��RESET_N ��������źŴ˴�����Ҫ�ظ�������ôֻ��Ҫ����ɨ�������
				k <= 4'b0;
			end
		else
			begin     //R��ÿ��ʱ�Ӵ���һ�μ�����mod 10���Ӷ� k ��ȡֵ��Χ [0~9]�����Բ����ظ�ɨ��
				case (j[(k * Byte/2) +: Byte/2])
					"Up": 
						begin
							if(Up_Queue[3:0] == 4'd0) //R��Up �� SW ���� == 0���Ѿ���ʼ�������˽����� Up ��׼��
                begin 
                  if(0 <= Code_Bit < 4)//R���ѳ�ʼ�� && ��������״̬ == ����¼��
                    begin
                      //R:�����ⲿӲ��״̬��i.e.��Up_Queue
											//R:�����µ� Up
                      Up_Queue[7:4] <= i; 
											//R: Up ������Ӽ���++
                      Up_Queue[3:0] <= Up_Queue[3:0] + 1;
                      //R�������ڲ��ź�״̬��i.e.��ʵ�� I/O
											//R����һλ��׼��¼��
                      Code_Bit <= Code_Bit + 1;
											//R������ i �������λ¼����Ӧ������
                      Code[(Code_Bit * Byte - 1) -:Byte] <= Up_Queue[7:4];
                    end
                  else//R���ѳ�ʼ�� && ��������λ����С��0 / ���ڵ���4�� == Ӳ���иı� ������¼��
                    begin
                      //R���ⲿӲ��״̬����Ҫ����ֻ�����ڲ��źŲ�����Ӧ�ĸ���
											//R:�����µ� Up��ע�⣡���ղ����� Up ���� Up_Queue[3:0] ����
                      Up_Queue[7:4] <= i;
											//R: Up ������Ӽ���++
                      Up_Queue[3:0] <= Up_Queue[3:0] + 1;
                      //R���������ڲ� I/O
                      Code_Bit <= Code_Bit;
                      Code <= Code;
                    end
                end
							else    //R����ǰ�Ѿ��� Up �� SW���������� Code_Bit �Լ죬ֱ�������ڲ� I/O
								      //R�����ⲿӲ��״̬������Ҫ��¼��
								begin
									Up_Queue[7:4] <= Up_Queue[7:4];//R:�������µ� Up 
									Up_Queue[3:0] <= Up_Queue[3:0] + 1;//R: ����Ҫ���� Up ��Ӽ���
									//R���������ڲ� I/O
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
					default://R��ĳ�� SW �����������ⲿӲ��״̬ & �ڲ� I/O �������ı�
            begin
              Up_Queue <= Up_Queue;
              Code_Bit <= Code_Bit;
              Code <= Code;
            end 
				endcase
				//R���л�����һλ����ɨ�裬���Խ��� case ƥ��� k�����ǵ�ǰ��Ҫɨ�账��� bit
				k <= (k + 1) % Mod;
			end
	end

  //R���� assign ������� always ���У�ʵ����ֻ�Ǳ����޸� input SW�����Ե��������źŽ�������
  assign SW_History_Out = SW;
endmodule
