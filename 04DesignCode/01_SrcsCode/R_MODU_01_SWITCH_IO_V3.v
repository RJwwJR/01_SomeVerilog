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

  ////R���ڲ��ź�
	//R��ѭ��������
  genvar i;
  //R���ȽϽ����־ Flag��ע��˴�������ÿһ�� SW �ĸı䶼����Ӧ�ļ�¼
	//R��ʵ�����ǣ�10 �� SW��ÿ�� SW ��Ҫ�� [1:0] ���б��� Up/Down/UnChange��һ�� 20 bit���������ֵ����ͻ
  reg [19:0] j;
	//R��ɨ���źż�����������ʮ�� SW ���ʱ������ɨ�裬���ڴ���ʱ�������ڶ�β�������ͻ������
	reg [3:0] k;

  parameter HalfByte = 4;
	parameter Mod_10 = 10;
  //R����Ӧ���������default ��������� UnChange ������δ֪����
	parameter UnChange = 2;
  parameter Up = 1;
  parameter Down = 0; 

/*
	//R����һ�� always �飬���ڵ�ƽ�źŵļ��
	always @ (posedge CLK or negedge RESET_N)
	begin
		if(!RESET_N)   //R��ϵͳ ͬ�� RESET_N �ĺ��壬���ڲ�������ȫ����Ϊ��ʼ̬
			begin
				//R�������ڲ��źţ����յ�ͬ����λҲ��Ҫ���и�λ
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
    //R����һ�� always �飬���ڵ�ƽ�źŵļ�������� always ���̿�ֻ��д�� generate ���ڲ�
    begin
      if(!RESET_N)   
      //R��ϵͳ ͬ�� RESET_N �ĺ��壬���ڲ�������ȫ����Ϊ��ʼ̬
        begin
          //R�������ڲ��źţ����յ�ͬ����λҲ��Ҫ���и�λ
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

	//R���ڶ��� always �飬�����еĵ�ƽ�仯����󣬿�ʼ��ʱ�����ɨ�裬������������ & ��ͻ����
	always @ (posedge CLK or negedge RESET_N) 
	begin
		if(!RESET_N)    
		//R��ע�⣬��ɨ���У�RESET_N �źŵĺ��壬�Ǵ�ͷ��ʼɨ�衣
			begin         
				//R��ע�⣬���� always �鲢�У���һ������ ��RESET_N ��������źŴ˴�����Ҫ�ظ�����
				//SW_CHANGE_FLAG <= { 0 , 0 }��Warning: Concatenation with unsized literal; will interpret as 32 bits
        SW_CHANGE_FLAG[0] <= 1'b0;
        SW_CHANGE_FLAG[1] <= 1'b0;
				WHICH_SW_CHANGE <= 4'hf;
				//R��Ӳ��״̬��¼���ֲ��䣬����ͬ�� RESET_N ֮������ Ӳ��״̬ ʵʩ�� ��ͻ/ì�ܴ��� ������Ч��
				UP_QUEUE <= UP_QUEUE;

				//R��ע�� SEQUENCE �ĸ�λ����������������ܼ��� 4'd��0000~9999��������ֻ����λ���ߣ�ȡ��һ������ֵҲ�ǿ��Ե�
				SEQUENCE <= 16'hffff; 
				SEQUENCE_BIT <= 3'b0;
				
				k <= 4'b0;
			end
		else
			begin     //R��ÿ��ʱ�Ӵ���һ�μ�����mod 10���Ӷ� k ��ȡֵ��Χ [0~9]�����Բ����ظ�ɨ��
				case (j[(k * HalfByte/2) +: HalfByte/2])
					"Up": 
						begin
							//R�����¶����ⲿ״̬�ĵ���ֱ���������ı䣬�� Up���� UP_QUEUE �Ƕ��ⲿӲ��״̬������ֱ������
							//R���ⲿ״̬�ĵ���ֱ���������иı����Ҫ���£�����Ҫ�������������źŽ����Լ���ݽ������
							//R�����ԣ��иı䣬����ֱ��������Ҫ��Ӧ�ı䣬����������δ��
							//SW_CHANGE_FLAG <= { Up , 1 };
              SW_CHANGE_FLAG[0] <= 1'b1;
              SW_CHANGE_FLAG[1] <= 1'b1;
							WHICH_SW_CHANGE <= k;

							if(UP_QUEUE[3:0] == 4'd0) 
							//R��Up �� SW ���� == 0���Ѿ���ʼ�������˽����� Up ��׼��
                begin 
									//R:�����ⲿӲ��״̬��i.e.��UP_QUEUE��SW_CHANGE_FLAG��WHICH_SW_CHANGE
									//R:�����µ� Up
									UP_QUEUE[7:4] <= i; 
									//R: Up ������Ӽ���++
									UP_QUEUE[3:0] <= UP_QUEUE[3:0] + 1;

									//R���ⲿӲ��״̬������֮�󣬲����ڲ� SEQUENCE_BIT �Լ�
                  if(0 <= SEQUENCE_BIT < 4)//R���ѳ�ʼ�� && ��������״̬ == ����¼��
                    begin
                      //R�������ڲ��ź�״̬��i.e.��ʵ�� I/O
											//R����һλ��׼��¼��
                      SEQUENCE_BIT <= SEQUENCE_BIT + 1;
											//R������ i �������λ¼����Ӧ������
                      SEQUENCE[(SEQUENCE_BIT * HalfByte - 1) -:HalfByte] <= UP_QUEUE[7:4];
                    end
                  else//R���ѳ�ʼ�� && ��������λ����С��0 / ���ڵ���4�� == Ӳ���иı� ������¼��
                    begin
                      //R���ⲿӲ��״̬����Ҫ����ֻ�����ڲ��źŲ�����Ӧ�ĸ���
											//R:�����µ� Up��ע�⣡���ղ����� Up ���� UP_QUEUE[3:0] ����
                      //UP_QUEUE[7:4] <= i;
											//R: Up ������Ӽ���++
                      //UP_QUEUE[3:0] <= UP_QUEUE[3:0] + 1;
                      //R���������ڲ� I/O
                      SEQUENCE_BIT <= SEQUENCE_BIT;
                      SEQUENCE <= SEQUENCE;
                    end
                end
							else    
							//R����ǰ�Ѿ��� Up �� SW���������� SEQUENCE_BIT �Լ죬ֱ�������ڲ� I/O
							//R�����ⲿӲ��״̬������Ҫ��¼��
								begin
									UP_QUEUE[7:4] <= UP_QUEUE[7:4];//R:�������µ� Up 
									UP_QUEUE[3:0] <= UP_QUEUE[3:0] + 1;//R: ����Ҫ���� Up ��Ӽ���
									//R���������ڲ� I/O
									SEQUENCE_BIT <= SEQUENCE_BIT;
									SEQUENCE <= SEQUENCE;
								end
						end
					"Down":
						begin
							//R������״̬����������ı�
							//SW_CHANGE_FLAG <= { Down , 1 };
              SW_CHANGE_FLAG[0] <= 1'b1;
              SW_CHANGE_FLAG[1] <= 1'b0;
							WHICH_SW_CHANGE <= k;

							//R��UP_QUEUE�����������Ӧ�ı�
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

							//R���ڲ����벻��
							SEQUENCE_BIT <= SEQUENCE_BIT;
              SEQUENCE <= SEQUENCE;
						end
					default://R��ĳ�� SW �����������ⲿӲ��״̬ & �ڲ� I/O �������ı�
            begin
							//R��ע�⣬����״̬������Flag[1] = 0 , WHICH_SW_CHANGE <= 4'hf���������⺬�帴�ã�ʵ�ʼ����Ҫ���ʹ��
							//SW_CHANGE_FLAG <= { 0 , 0 };
              SW_CHANGE_FLAG[0] <= 1'b0;
              SW_CHANGE_FLAG[1] <= 1'b0;
							WHICH_SW_CHANGE <= 4'hf;
              UP_QUEUE <= UP_QUEUE;
              SEQUENCE_BIT <= SEQUENCE_BIT;
              SEQUENCE <= SEQUENCE;
            end 
				endcase
				//R���л�����һλ����ɨ�裬���Խ��� case ƥ��� k�����ǵ�ǰ��Ҫɨ�账��� bit
				k <= (k + 1) % Mod_10;
			end
	end

  //R���� assign ������� always ���У�ʵ����ֻ�Ǳ����޸� input SW�����Ե��������źŽ�������
  assign SW_HISTORY_OUT = SW;
endmodule
