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
  //R��һ��BTN & RESET ����ʹ�� BUTTON ���п��ƣ�Ϊ������ BTN ��ƽ�ź� ��ת�����ڲ��� ��λ�źţ�ͳһ�����߱�ʾ BTN
  input [3:0] BTN,
  
  output [7:0] AN,
  output [7:0] SEG,
  output [15:0] LD
  );

  ////R�����ڽ��ⲿ��ƽ�ź����ڲ��ɴ����źŽ���������ϡ���Ƶ������������ڲ��ź�

  ///R��Ϊ���� SW ��ƽ�źţ����õ��ڲ��ź�
  //R���� 0/1 Flag ���� SW ��ƽ�ź��Ƿ�ı䣬0�������䣬1�����ı�
  //reg Code_Change_Flag;//R�����㹻����Ϊ���ڳ�ͻ�Ĵ�����Ҫ��ȷ֪�������ĸ� SW ������ UP/DOWN �����ı仯
  //R���ø�Ϊϸ�µķ�ʽ���б�����Ϊ���жϾ����ĸ� SW �����������ı仯����Ҫ��¼��ʷ ��ƽ ������бȽ�
  //R��Ϊ���ڱȽϺ� SW_History ���и��£��� input/output �и���һ�� History �ı����������ִ�к����
  reg [9:0] SW_History;
  reg [9:0] SW_History_Out;
  //R����λ bus��[0]���������Ƿ�ı�� Flag��[1]��������Up/Down �� Flag
  reg [1:0] SW_Change_Flag;
  //R�����õ�������ֵ�Ĵ�С��4'd[0~9]
  reg [3:0] Which_SW_Change;
  //R��[7:4]����������һ�� Up��[3:0]���������м��� Up
  reg [7:0] Up_Queue;
  
  //R����ȡ SW ��ƽ�źź�洢���ڲ��� Code & Key
  reg [15:0] Key;
  reg [15:0] Code;
  //R����¼�Ѿ������ Code bit�����е�ȡֵ��Χ��������0,1,2,3,4��������Ҫ��λ����
  reg [2:0] Code_Bit;

  ///R��Ϊ���� BTN ��ƽ�źţ����õ�һ���ڲ��ź�
  //R���� 0/1 Flag ���� BTN ��ƽ�ź��Ƿ�ı䣬0�������䣬1�����ı�
  reg BTN_Change_Flag;
  //R���� Which ����������һ�� BTN �����ر�������ע�� RESET �Ѿ���������ȥ
  reg [1:0] Which_BTN_Posedge;
  //R���� 4 �������0/1/2/3��ʮ���Ʊ�ʾ
  //R����Ӧ��ϵ�������� BTN_RESET����BTN[0]��BTN_ADMIN����BTN[1]��BTN_OK����BTN[2]��BTN_BACKSPACE����BTN[3]
  parameter BTN_RESET = 0;
  parameter BTN_ADMIN = 1;
  parameter BTN_OK = 2;
  parameter BTN_BACKSPACE = 3;
  
  ///R�����ڸ���������ڲ��ź�
  //R����ֵ�߼��� 0/1 Flag ��������ƥ���Ƿ���ȷ
  reg Correct_Flag;
  //R��ʮ�����źţ����ڴ��������ͳ�ƣ������� 1/2/3 ����ȡֵ���
  reg [1:0] Rrror_Time;
  //R�����ڷ�Ƶ������µ�ʱ���źţ����� 1ms������ϵͳʱ�ӻ��� ns ���𣬶�����Ҫ ms �����ʱ�ӵ�ģ�飬��������ʵ��������
  //reg [4:0] M_Clock;
  
  
  //R��״̬�Ĵ�
  reg [2:0] Current_State;
  reg [2:0] Next_State;
  
  //R��״̬����
  parameter WAIT = 3'b000;
  parameter INPUT = 3'b001;
  parameter UNLOCK = 3'b010;
  parameter ERROR = 3'b011;
  parameter ALARM = 3'b100;

  //R:״̬�Ĵ� & ת���߼�
  always @ (posedge CLK or posedge RESET)
  begin 
    if(RESET == 1)
      Current_State <= WAIT;
    else
    Current_State <= Next_State;
  end

  //R����̬�߼�,��λ�Ѿ��ڴ�̬�߼���д�����˴��Ѿ������ٿ���
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
