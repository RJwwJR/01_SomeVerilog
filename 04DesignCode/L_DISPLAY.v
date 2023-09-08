`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2023/09/08 20:18:42
// Design Name: 
// Module Name: L_DISPLAY
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


module L_DISPLAY(
    input CLK,
    input CLK1,
    input Current_State,
    input  Error_times,
    input [15:0] Code,
    output reg [7:0] AN,
    output reg [7:0] SEG
    );
     reg [2:0] num;
     parameter WAIT = 3'b000;
     parameter INPUT = 3'b001;
     parameter UNLOCK = 3'b010;
     parameter ERROR = 3'b011;
     parameter ALARM = 3'b100;
     parameter ADMIN = 3'b101;
     
     
     function disp;      //disp���������ڽ�0-9������ת��Ϊ����SEG��ʾ
     input [3:0] x;
     reg [7:0] seg7;
     begin
       case(x)
         10 : seg7 = 8'b11111111;
         0 : seg7 = 8'b00000011;
         1 : seg7 = 8'b10011111;
         2 : seg7 = 8'b00100101;
         3 : seg7 = 8'b00001101;
         4 : seg7 = 8'b10011001;
         5 : seg7 = 8'b01001001;
         6 : seg7 = 8'b01000001;
         7 : seg7 = 8'b00011111;
         8 : seg7 = 8'b00000001;
         9 : seg7 = 8'b00001001;
        endcase
      disp = (seg7);
     end
   endfunction
     
     
     always @(posedge CLK1)
       begin
         if(Current_State == WAIT)     //�ȴ�״̬�£���ʾ____
           begin
             if(num >= 3)
               num <= 0;
             else 
               num <= num + 1;
           case(num)
             0:begin
                 AN <= 8'b01111111;
                 SEG <= 8'b11101111;
               end
             1:begin
                 AN <= 8'b10111111;
                 SEG <= 8'b11101111;
               end
             2:begin
                 AN <= 8'b11011111;
                 SEG <= 8'b11101111;
               end 
             3:begin
                 AN <= 8'b11101111;
                 SEG <= 8'b11101111;
               end                       
             endcase
           end
         else if(Current_State == INPUT)  //����״̬�£���ʾÿһλ���������
           begin
             if(num >= 4)
               num <= 0;
             else 
               num <= num + 1;
           case(num)
             0:begin
                 AN <= 8'b01111111;
                 SEG <= disp(Code[3:0]);
               end
             1:begin
                 AN <= 8'b10111111;
                 SEG <= disp(Code[7:4]);
               end
             2:begin
                 AN <= 8'b11011111;
                 SEG <= disp(Code[11:8]);
               end 
             3:begin
                 AN <= 8'b11101111;
                 SEG <= disp(Code[15:12]);
               end
             4:begin
                 AN <= 8'b11111110;
                 SEG <= disp(Error_times);
               end                        
             endcase
           end
         
         else if(Current_State == UNLOCK)  //����״̬�£���ʾHELLO
           begin
             if(num >= 4)
               num <= 0;
             else num <= num + 1;
             case(num)
               0:begin
                 AN <= 8'b01111111;
                 SEG <= 8'b10010001;
               end            
               1:begin
                 AN <= 8'b10111111;
                 SEG <= 8'b01100001;
               end
             2:begin
                 AN <= 8'b11011111;
                 SEG <= 8'b11100011;
               end 
             3:begin
                 AN <= 8'b11101111;
                 SEG <= 8'b11100011;
               end     
             4:begin
                 AN <= 8'b11110111;
                 SEG <= 8'b00000011;
               end                  
             endcase
           end
           
           else if(Current_State == ERROR)    //����״̬�£���ʾERROR
             begin
             if(num >= 4)
               num <= 0;
             else num <= num + 1;
             case(num)
               0:begin
                 AN <= 8'b01111111;
                 SEG <= 8'b01100001;
               end            
               1:begin
                 AN <= 8'b10111111;
                 SEG <= 8'b00010001;
               end
             2:begin
                 AN <= 8'b11011111;
                 SEG <= 8'b00010001;
               end 
             3:begin
                 AN <= 8'b11101111;
                 SEG <= 8'b00000011;
               end     
             4:begin
                 AN <= 8'b11110111;
                 SEG <= 8'b00010001;
               end                  
             endcase
           end
               
           else if(Current_State == ALARM)   //����״̬�£���ʾEEEE
             begin
             if(num >= 3)
               num <= 0;
             else num <= num + 1;
             case(num)
               0:begin
                 AN <= 8'b01111111;
                 SEG <= 8'b01100001;
               end            
               1:begin
                 AN <= 8'b10111111;
                 SEG <= 8'b01100001;
               end
             2:begin
                 AN <= 8'b11011111;
                 SEG <= 8'b01100001;
               end 
             3:begin
                 AN <= 8'b11101111;
                 SEG <= 8'b001100001;
               end                      
             endcase
           end
         
           else if(Current_State == ADMIN)     //����Ա�޸�����״̬�£���ʾÿһλ���������
             begin
               if(num >= 3)
                 num <= 0;
               else
                 num <= num + 1;
               case(num)
                 0:begin
                     AN <= 8'b01111111;
                     SEG <= disp(Code[3:0]);
                   end
                1:begin
                    AN <= 8'b10111111;
                    SEG <= disp(Code[7:4]);
                  end
                2:begin
                    AN <= 8'b11011111;
                    SEG <= disp(Code[11:8]);
                  end 
                3:begin
                    AN <= 8'b11101111;
                    SEG <= disp(Code[15:12]);
                  end
                4:begin
                    AN <= 8'b11111111;
                  end                        
               endcase
           end
       end
   
endmodule

