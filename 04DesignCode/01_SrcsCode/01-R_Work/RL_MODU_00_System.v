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

//����������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������
  ////R����������
  //R���� 4 �������0/1/2/3��ʮ���Ʊ�ʾ
  //R����Ӧ��ϵ�������� BTN_RESET����BTN[0]��BTN_ADMIN����BTN[1]��BTN_OK����BTN[2]��BTN_BACKSPACE����BTN[3]
  parameter BTN_RESET = 0;
  parameter BTN_ADMIN = 1;
  parameter BTN_OK = 2;
  parameter BTN_BACKSPACE = 3;
  //R�����ó���
  parameter Mod_10 = 10;
  //R��״̬����
  parameter WAIT = 3'd0;
  parameter INPUT = 3'd1;
  parameter ERROR = 3'd2;
  parameter ALARM = 3'd3;
  parameter UNLOCK = 3'd4;

//����������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������
  ////R���ڲ��ź�
  //R��״̬�Ĵ�
  reg [2:0] Current_State;
  reg [2:0] Next_State;
//��������������������������������������������������������������������������������������������������������������������������������������������������������������
  ////R��Ϊ���� SW ��ƽ�źţ����õ��ⲿӲ�������ź�
  //R���� 0/1 Flag ���� SW ��ƽ�ź��Ƿ�ı䣬0�������䣬1�����ı�
  //reg Code_Change_Flag;//R�����㹻����Ϊ���ڳ�ͻ�Ĵ�����Ҫ��ȷ֪�������ĸ� SW ������ UP/DOWN �����ı仯
  //R���ø�Ϊϸ�µķ�ʽ���б�����Ϊ���жϾ����ĸ� SW �����������ı仯����Ҫ��¼��ʷ ��ƽ ������бȽ�
  //R��Ϊ���ڱȽϺ� SW_History ���и��£��� input/output �и���һ�� History �ı����������ִ�к����
  reg [9:0] SW_History;
  //R����λ bus��[0]���������Ƿ�ı�� Flag��0����No��1����Yes
  //R��[1]��������Up/Down �� Flag
  wire [1:0] SW_Change_Flag;
  //R�����õ�������ֵ�Ĵ�С��4'd[0~9]
  wire [3:0] Which_SW_Change;
  //R��[7:4]����������һ�� Up��[3:0]���������м��� Up
  wire [7:0] Up_Queue;
//��������������������������������������������������������������������������������������������������������������������������������������������������������������
  //R����ȡ SW ��ƽ�źź�洢���ڲ��� Code & Key���������ڲ��ź�
  reg [15:0] Key;
  reg [2:0] Key_Bit;
  reg [15:0] Code;
  //R����¼�Ѿ������ Code bit�����е�ȡֵ��Χ��������0,1,2,3,4��������Ҫ��λ����
  reg [2:0] Code_Bit;
  //R���������� SW �������źţ���Ϊ������ʱ����ת
  reg [9:0] SW_History_Mid;
  //R������ͬ�� ����ģ�� & SW_IO ģ���ɨ���ź�
  reg [3:0] Scan_Counter;
  wire [19:0] SW_Difference;
//��������������������������������������������������������������������������������������������������������������������������������������������������������������
  ///R��Ϊ���� BTN ��ƽ�źţ����õ�һ���ⲿӲ�������ź��ź�
  //R���� 0/1 Flag ���� BTN ��ƽ�ź��Ƿ�ı䣬0�������䣬1�����ı�
  wire BTN_Change_Flag;
  //R���� Which ����������һ�� BTN �����ر�������ע�� RESET �Ѿ���������ȥ
  wire [1:0] Which_BTN_Posedge;
//��������������������������������������������������������������������������������������������������������������������������������������������������������������
  //R����ȡ BTN ��ƽ�����غ��������ڲ��ź�
  reg [3:0] Signal_BTN;
//��������������������������������������������������������������������������������������������������������������������������������������������������������������
  ///R�����ڸ���������ڲ��ź�
  //R���������� ADMIN/USER Ȩ�ޣ�ADMIN = 1��Ĭ�ϸ�λ�� USER = 0
  reg Id_Flag;
  //R��ϵͳ�Ƿ���������������״̬
  reg Lock_Flag;
  //R��ʮ�����źţ����ڴ��������ͳ�ƣ������� 1/2/3 ����ȡֵ���
  reg [1:0] Error_Time;

//����������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������
  //R���� BTN �ĵ�ƽ���ģ��ʵ����
  BTN_IO BTN_IO_inst(
    .CLK(CLK),
    .RESET(Signal_BTN[BTN_RESET]),
    .BTN(BTN),
//������������������������������������������������������������������������������
    .BTN_CHANGE_FLAG(BTN_Change_Flag),
    .WHICH_BTN_POSEDGE(Which_BTN_Posedge)
  );
//��������������������������������������������������������������������������������������������������������������
  //R������ BTN ��������ɨ����������뵽�ڲ��ź� "Signal_BTN = �ĸ���ť������"��û�����ÿ�
  //R�������źű����� CLK��������û�а�ť������ʱ�Ż�� Signal_BTN �Զ���ʼ��
  always @ (posedge CLK)
  begin
    if(BTN_Change_Flag)
    begin
      Signal_BTN <= 4'b0;
      case (Which_BTN_Posedge)
        "BTN_RESET":     Signal_BTN[BTN_RESET] <= 1;
        "BTN_ADMIN":     Signal_BTN[BTN_ADMIN] <= 1;
        "BTN_OK":        Signal_BTN[BTN_OK] <= 1;
        "BTN_BACKSPACE": Signal_BTN[BTN_BACKSPACE] <= 1;
        //R�����ָ����� ��λ
        default:         Signal_BTN <= 4'b0;
      endcase
    end
    else                 Signal_BTN <= 4'b0;
  end

//��������������������������������������������������������������������������������������������������������������������������������������������������������������
  //R���� SWITCH �ĵ�ƽ���ģ��ʵ����
  SWITCH_IO_V4 SWITCH_IO_V4_inst(
    .CLK(CLK),
    .RESET(Signal_BTN[BTN_RESET]),
    .SW(SW),
    .SW_HISTORY(SW_History),
    .SCAN_COUNTER(Scan_Counter),
//������������������������������������������������������������������������������
    .SW_CHANGE_FLAG(SW_Change_Flag),
    .WHICH_SW_CHANGE(Which_SW_Change),
    .UP_QUEUE(Up_Queue),
//������������������������������������������������������������������������������
    .SW_DIFFERENCE(SW_Difference)
  );
//��������������������������������������������������������������������������������������������������������������
  //R������ɨ���ź�
  always @ (posedge CLK)
  Scan_Counter <= (Scan_Counter + 1) % Mod_10;
//��������������������������������������������������������������������������������������������������������������
  //R����ʱ���β��� SW_History �ź�
  always @ (posedge CLK) 
  SW_History_Mid <= SW;
  always @ (posedge CLK)
  SW_History <= SW_History_Mid;
//��������������������������������������������������������������������������������������������������������������
  //R������ Curren_State��Id_Flag��Bit ������ SWITCH ��ƽ�������봦��
  
  always @ (posedge CLK) 
  begin
    if((Current_State != WAIT) && (Current_State != INPUT))
    //R��������״̬������Ҫ�������룬������������룬��ƽҪ����
    //R����ƽ����Ϊ������֮����ʾ����������л��۵����
    begin
      
    end
    else
    //R��Current_State ����������������һ�����ݱ仯��־λ�ж��Ƿ���Ҫ����
      if (BTN_Change_Flag) begin
      //R������� BTN �ı仯���ȶ� BTN �ı仯���д���
      //R����Ϊָ�� BTN �����ȼ����� SW

        
      end else begin
        
      end
  end


//��������������������������������������������������������������������������������������������������������������������������������������������������������������
  //R:״̬�Ĵ� & ת���߼�
  always @ (posedge CLK or posedge Signal_BTN[BTN_RESET])
  begin
  if(Signal_BTN[BTN_RESET])
    Current_State <= WAIT;
  else
    Current_State <= Next_State;
  end

//��������������������������������������������������������������������������������������������������������������������������������������������������������������
  //R����̬�߼�,��λ�Ѿ���״̬�Ĵ���д�����˴��Ѿ������ٿ���
  always @ (Current_State or SW_Change_Flag[0] or BTN_Change_Flag)
  begin
    case(Current_State)
      "WAIT":
      begin
        if(SW_Change_Flag[0] || Signal_BTN[BTN_ADMIN])
          Next_State = INPUT;
        else
          Next_State = WAIT;
      end
      "INPUT":
      begin
        if (SW_Change_Flag[0] || Signal_BTN[BTN_ADMIN] || Signal_BTN[BTN_BACKSPACE]) 
          Next_State = INPUT;
        else if(Signal_BTN[BTN_OK])
        begin
          if(Id_Flag)
          //R��Id_Flag == 1.����ԱȨ��
          begin
            if(Key_Bit == 4)
            //R���µ�����������ɣ��ص��ȴ�״̬
              Next_State = WAIT;
            else
            //R������δ��ȫ���ص� Bit = 0 ��״̬��������
              Next_State = INPUT;
          end
          else
          //R��Id_Flag == 0���ǹ���ԱȨ��,
          begin
            if(Key_Bit == 4)
            //R������λ����ȷ���ټ���Ƿ�ƥ��
              if(Code == Key)
              //R��ƥ�䣬����
                Next_State = UNLOCK;
              else
              //R����ƥ�䣬�������++������Ӧ��� ERROR/ALARM
              begin
                Error_Time = Error_Time + 1;
                if(Error_Time == 3)
                  Next_State = ALARM;
                else
                  Next_State = ERROR;
              end
            else
            //R������λ������ȷ������������ӣ������ݴ�������ٷ�֧
            begin
              Error_Time = Error_Time + 1;
              if(Error_Time == 3)
                Next_State = ALARM;
              else
                Next_State = ERROR;
            end
          end
        end
        else
        //R��ʣ�����������ֻ�а��� BTN_RESET ʱ��ʣ���쳣�����λ WAIT һ������ 
          Next_State = WAIT;
      end
      "ERROR":
      begin
        if(SW_Change_Flag[0]
          || Signal_BTN[BTN_BACKSPACE] || Signal_BTN[BTN_OK])
        //R��SW/ĳЩ�����仯,�����ص� INPUT�������������루����������������
        begin
          Error_Time = Error_Time;
          Next_State = INPUT;
        end
        else
        //R���й���ԱȨ��/reset����Ϊ�������ֱ����գ��ص�����״̬
        begin
          Error_Time = 0;
          Next_State = WAIT;
        end
      end
      "ALARM":
      begin
        if(Signal_BTN[BTN_OK] || Signal_BTN[BTN_BACKSPACE]
          || SW_Change_Flag[0])
        //R��������Ч����������
        begin
          Error_Time = Error_Time;
          Next_State = ALARM;
        end
        else
        //R������Ա��ֹ����/��λ/�Ŷ������»ص��ȴ�����
        begin
          Error_Time = 0;
          Next_State = WAIT;
        end
      end
      "UNLOCK":
      begin
        //R����������ǰ�Ĵ������һ�����
        Error_Time = 0;
        if(Signal_BTN[BTN_ADMIN] || Signal_BTN[BTN_RESET])
        //R����λ�����
         Next_State = WAIT;
        else
        //R�������������Ĳ��������������
          Next_State = UNLOCK;
      end
      default:
        Next_State = WAIT;
    endcase
  end
endmodule
