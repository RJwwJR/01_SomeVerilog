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
module Key_jitter(
  input clk,
  input key_in,//���������ź�
  output key_posedge//���������ؼ���źţ������
    );
  //�ڲ��ź�
  reg [1:0] key_in_r;//��������ļĴ���
  wire kk;  //����״̬�Ĵ���
  reg [19:0] count;//������
  reg key_value_r = 0;//����ֵ�ļĴ���
  reg key_value_rd = 0;//����ֵ�ļĴ�������ʱһ��ʱ�����ڣ�
  //����ǰ�İ������뱣�浽key_in�Ĵ�����
  always @(posedge clk)
    key_in_r <= {key_in_r[0],key_in};
  //�����������û�б仯
  assign kk = key_in_r[0]^key_in_r[1];
  
  always @(posedge clk)
    if(kk == 1'b1)
      count <= 20'h0;//������⵽���������б仯����������0
    else 
      count <= count + 1;
   //count�����ֵʱ������ǰkey_in_r[0]����key_value_r 
   always @(posedge clk)
     if(count == 20'hffff)
       key_value_r <= key_in_r[0];
   //������ʱ��ֵ��ʵ��һ��ʱ�����ڵ��ӳ�
   always @(posedge clk)
     key_value_rd <= key_value_r;
   //��key_posedge��ֵΪ���������ؼ���źţ�������������ʱΪ�߼���
   assign key_posedge = key_value_r & ~key_value_rd;
       
endmodule
