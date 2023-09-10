`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2023/09/10 15:57:06
// Design Name: 
// Module Name: SWITCH_IO_V4
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


module SWITCH_IO_V4(
  input CLK,
  input RESET,
  input [9:0] SW,
  input [9:0] SW_HISTORY,
  input [3:0] SCAN_COUNTER,

  output reg [1:0] SW_CHANGE_FLAG,
  output reg [3:0] WHICH_SW_CHANGE,
  output reg [7:0] UP_QUEUE,

  output reg [19:0] SW_DIFFERENCE
  );
//����������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������
  //R����������
  parameter HalfByte = 4;
  parameter None = 4'hf;
  //R����Ӧ���������default ��������� UnChange ������δ֪����
  parameter Down = 0; 
  parameter Up = 1;
	parameter UnChange = 2;
//����������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������
  ////R���ڲ��ź�
  //R��ѭ��������
  genvar i;

//����������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������
  generate for ( i = 0; i < 10 ; i = i + 1)
  begin:SWITCH_IO_V4_Generate_Block_1
    always @ (posedge CLK or posedge RESET)
    //R����һ�� always �飬���ڵ�ƽ�źŵļ�������� always ���̿�ֻ��д�� generate ���ڲ�
    begin
      if(RESET)   
      //R��ϵͳ ͬ�� RESET �ĺ��壬���ڲ�������ȫ����Ϊ��ʼ̬
        begin
          //R�������ڲ��źţ����յ�ͬ����λҲ��Ҫ���и�λ
          SW_DIFFERENCE <= 20'b0;
        end
      else
        begin
          if (SW[i] < SW_HISTORY[i]) 
          SW_DIFFERENCE[(i * HalfByte/2) +: HalfByte/2] <= Down;
          else if (SW[i] > SW_HISTORY[i]) 
          SW_DIFFERENCE[(i * HalfByte/2) +: HalfByte/2] <= Up;
          else 
          SW_DIFFERENCE[(i * HalfByte/2) +: HalfByte/2] <= UnChange;
        end
    end
  end
  endgenerate

//����������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������
  always @ (posedge CLK or posedge RESET)
  begin
    if(RESET)
    begin
      SW_CHANGE_FLAG[0] <= 1'b0;
      SW_CHANGE_FLAG[1] <= 1'b0;
      WHICH_SW_CHANGE <= None;

      //R��Ӳ��״̬��¼���ֲ��䣬����ͬ�� RESET_N ֮������ Ӳ��״̬ ʵʩ�� ��ͻ/ì�ܴ��� ������Ч��
      UP_QUEUE <= UP_QUEUE;
    end
    else
    begin
      case(SW_DIFFERENCE[(SCAN_COUNTER * HalfByte/2) +: HalfByte/2])
      "Up":
      begin
        SW_CHANGE_FLAG[0] <= 1'b1;
        SW_CHANGE_FLAG[1] <= 1'b1;
        WHICH_SW_CHANGE <= SCAN_COUNTER;
        //����������������������������������������������������������������������
        if(UP_QUEUE[3:0] == 4'd0)
        begin
          UP_QUEUE[7:4] <= SCAN_COUNTER; 
          UP_QUEUE[3:0] <= UP_QUEUE[3:0] + 1;
        end
        //����������������������������������������������������������������������
        else
        begin
          //R:�������µ� Up 
          UP_QUEUE[7:4] <= UP_QUEUE[7:4];
          //R: ����Ҫ���� Up ��Ӽ���
          UP_QUEUE[3:0] <= UP_QUEUE[3:0] + 1;
        end
      end
      //������������������������������������������������������������������������������������������������
      "Down":
      begin
        //R������״̬����������ı�
        //SW_CHANGE_FLAG <= { Down , 1 };
        SW_CHANGE_FLAG[0] <= 1'b1;
        SW_CHANGE_FLAG[1] <= 1'b0;
        WHICH_SW_CHANGE <= SCAN_COUNTER;
        //����������������������������������������������������������������������
        //R��UP_QUEUE�����������Ӧ�ı�
        if((UP_QUEUE[3:0] == 4'd0) || (UP_QUEUE[3:0] == 4'd1))
          begin
            UP_QUEUE[3:0] <= 4'd0;
            UP_QUEUE[7:4] <= None;
          end
        //����������������������������������������������������������������������
        else
          begin
            UP_QUEUE[3:0] <= UP_QUEUE[3:0] - 1;
            UP_QUEUE[7:4] <= UP_QUEUE[7:4];
          end
      end
      //������������������������������������������������������������������������������������������������
      default
      begin
        //R��ע�⣬����״̬������Flag[1] = 0 , WHICH_SW_CHANGE <= 4'hf���������⺬�帴�ã�ʵ�ʼ����Ҫ���ʹ��
        //SW_CHANGE_FLAG <= { 0 , 0 };
        SW_CHANGE_FLAG[0] <= 1'b0;
        SW_CHANGE_FLAG[1] <= 1'b0;
        WHICH_SW_CHANGE <= None;
        UP_QUEUE <= UP_QUEUE;
      end
      endcase
    end
  end
  
endmodule
