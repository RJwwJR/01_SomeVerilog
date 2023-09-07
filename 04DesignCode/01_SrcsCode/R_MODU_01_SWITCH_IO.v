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
  //input CLK,//R������߼������������ƺ����漰ʱ�ӵĲ�����
  input RESET;
  input [9:0] SW,
  input [9:0] SW_History,

  //R��Ϊ�˱���֮�� always ���ڸ�ֵ���� reg��wire ��ת����ֱ�Ӷ���� reg
  output reg [7:0] Up_Queue,
  output wire [9:0] SW_History_Out,
  output reg [15:0] Code,
  output reg [2:0] Code_Bit);

  //R��ѭ��������
  reg [3:0] i;
  //R���ȽϽ����־ Flag
  reg [1:0] j;
  parameter Byte = 4;
  //R����Ӧ j �ĸ������
  parameter Up = 1;
  parameter Down = 0; //R���ƺ� parameter ���ܸ���������
  
  ////R:�������ı䣬���������źţ����� SWITCH ��ƽ�ı�δ�غ�ʱ��һ�£����Ӧ��Ϊ����߼�
  always@ (SW or negedge RESET)
  begin
   if(!RESET)//R��RESET ���������
    begin
      //R��Ӳ��״̬��¼���ֲ��䣬�����첽 RESET ֮������ Ӳ��״̬ ʵʩ�� ��ͻ/ì�ܴ��� ������Ч��
      Up_Queue = Up_Queue;
      //R��ϵͳ �첽RESET �ĺ��壬���ڲ�������ȫ����Ϊ��ʼ̬
      Code = 16'hffff; //R��ע�� Code �ĳ�ʼ̬����������������ܼ��У�����ֻ����λ���ߣ�ȡ��һ������ֵҲ�ǿ��Ե�
      Code_Bit = 3'b0;
    end
   else
    begin
      for ( i = 4'd0; i <= 4'd9 ; i = i + 1)
        begin
          //R��ͨ���Ƚϣ�����ֵ�����ӳ�䵽 0/1/2 ���֣�����ʹ�� integrer
          if (SW[i] > SW_History[i]) j = 1;
          else if (SW[i] < SW_History[i]) j = 0;
          else j = 2;
          case(j)
          "Up":
            begin
              if(Up_Queue[3:0] == 4'd0) //R��Up �� SW ���� == 0���Ѿ���ʼ�������˽����� Up ��׼��
                begin 
                  if(0 <= Code_Bit < 4)//R���ѳ�ʼ�� && ��������״̬ == ����¼��
                    begin
                      //R:�����ⲿӲ��״̬��i.e.��Up_Queue
                      Up_Queue[7:4] = i;//R:�����µ� Up 
                      Up_Queue[3:0] = Up_Queue[3:0] + 1;//R: Up ������Ӽ���++
                      //R�������ڲ��ź�״̬��i.e.��ʵ�� I/O
                      Code_Bit = Code_Bit + 1;//R����һλ��׼��¼��
                      Code[(Code_Bit * Byte - 1) -:Byte] = Up_Queue[7:4];//R������ i �������λ¼����Ӧ������
                    end
                  else//R���ѳ�ʼ�� && ��������λ����С��0 / ���ڵ���4�� == Ӳ���иı� ������¼��
                    begin
                      //R���ⲿӲ��״̬����Ҫ����ֻ�����ڲ��źŲ�����Ӧ�ĸ���
                      Up_Queue[7:4] = i;//R:�����µ� Up��ע�⣡���ղ����� Up ���� Up_Queue[3:0] ����
                      Up_Queue[3:0] = Up_Queue[3:0] + 1;//R: Up ������Ӽ���++
                      //R���������ڲ� I/O
                      Code_Bit = Code_Bit;
                      Code = Code;
                    end
                end
              else//R����ǰ�Ѿ��� Up �� SW���������� Code_Bit �Լ죬ֱ�������ڲ� I/O
              //R�����ⲿӲ��״̬������Ҫ��¼��
              begin
                Up_Queue[7:4] = Up_Queue[7:4];//R:�������µ� Up 
                Up_Queue[3:0] = Up_Queue[3:0] + 1;//R: ����Ҫ���� Up ��Ӽ���
                //R���������ڲ� I/O
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
          default://R��ĳ�� SW �����������ⲿӲ��״̬ & �ڲ� I/O �������ı�
            begin
              Up_Queue = Up_Queue;
              Code_Bit = Code_Bit;
              Code = Code;
            end
          endcase
        end
    end
  end

  //R���� assign ������� always ���У�ʵ����ֻ�Ǳ����޸� input SW�����Ե��������źŽ�������
  assign SW_History_Out = SW;
endmodule
