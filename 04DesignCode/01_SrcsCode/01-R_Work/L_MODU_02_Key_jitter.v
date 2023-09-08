`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2023/09/05 19:56:09
// Design Name: 
// Module Name: Key_jitter
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

//�ڰ����źű仯���һ��ʱ���ڣ���������źŲ������仯����Ϊ�а������£�����״̬�Ĵ�����1��
//��������źŷ����ı䣬��Ϊ����������״̬�Ĵ�����Ϊ0
module BTN_JITTER(
  input CLK,
  input BTN_IN,//���������ź�
  output BTN_POSEDGE//���������ؼ���źţ������
    );
  //�ڲ��ź�
  reg [1:0] BTN_IN_R;//��������ļĴ���
  wire BTN_STATE;  //����״̬�Ĵ���
  reg [19:0] count;//������
  reg BTN_VALUE_R = 0;//����ֵ�ļĴ���
  reg BTN_VALUE_RD = 0;//����ֵ�ļĴ�������ʱһ��ʱ�����ڣ�
  //����ǰ�İ������뱣�浽BTN_IN�Ĵ�����
  always @(posedge CLK)
    BTN_IN_R <= {BTN_IN_R[0], BTN_IN};
  //�����������û�б仯
  assign BTN_STATE = BTN_IN_R[0] ^ BTN_IN_R[1];
  
  always @(posedge CLK)
    if(BTN_STATE == 1'b1)
      count <= 20'h0;//������⵽���������б仯����������0
    else 
      count <= count + 1;
   //count�����ֵʱ������ǰBTN_IN_r[0]����BTN_VALUE_r 
   always @(posedge CLK)
     if(count == 20'hffff)
       BTN_VALUE_R <= BTN_IN_R[0];
   //������ʱ��ֵ��ʵ��һ��ʱ�����ڵ��ӳ�
   always @(posedge CLK)
     BTN_VALUE_RD <= BTN_VALUE_R;
   //��BTN_POSEDGE��ֵΪ���������ؼ���źţ�������������ʱΪ�߼���
   assign BTN_POSEDGE = BTN_VALUE_r & ~BTN_VALUE_rd;
       
endmodule
