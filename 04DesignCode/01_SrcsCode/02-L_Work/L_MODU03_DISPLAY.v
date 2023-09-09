`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2023/09/09 20:31:28
// Design Name: 
// Module Name: L_MODU03_DISPLAY
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


module L_MODU03_DISPLAY(
    input CLK,
    input CLK1,
    input Current_State,
    input  Error_Times,
    input [15:0] Code,
    input [19:0] COUNT_CLK,
    output reg [7:0] AN,
    output reg [7:0] SEG,
    output reg [9:0] LED
    );
     reg [2:0] num;
     parameter WAIT = 3'b000;
     parameter INPUT = 3'b001;
     parameter UNLOCK = 3'b010;
     parameter ERROR = 3'b011;
     parameter ALARM = 3'b100;
     parameter ADMIN = 3'b101;
     
     parameter ten_s = 500000;
     parameter twenty_s = 1000000; 
     
     always @(posedge CLK)        //LED的流水计时工作，10个LED灯在不同的状态下分别进行10s和20s倒计时
     begin
       if(UNLOCK == 1)
         begin
           if(COUNT_CLK > 900000) LED <= 10'b1111111111;
           else if(COUNT_CLK < 900000 & COUNT_CLK > 800000) LED <= 10'b0111111111;
           else if(COUNT_CLK < 800000 & COUNT_CLK > 700000) LED <= 10'b0111111111;
           else if(COUNT_CLK < 700000 & COUNT_CLK > 600000) LED <= 10'b0011111111;
           else if(COUNT_CLK < 600000 & COUNT_CLK > 500000) LED <= 10'b0001111111;
           else if(COUNT_CLK < 500000 & COUNT_CLK > 400000) LED <= 10'b0000111111;
           else if(COUNT_CLK < 400000 & COUNT_CLK > 300000) LED <= 10'b0000011111;
           else if(COUNT_CLK < 300000 & COUNT_CLK > 200000) LED <= 10'b0000001111;
           else if(COUNT_CLK < 200000 & COUNT_CLK > 100000) LED <= 10'b00000000111;
           else if(COUNT_CLK < 100000 & COUNT_CLK > 0) LED <= 10'b00000000001;
           else LED <= 10'b0000000000;
         end
       else
         begin
           if(COUNT_CLK > 450000) LED <= 10'b1111111111;
           else if(COUNT_CLK < 450000 & COUNT_CLK > 400000) LED <= 10'b0111111111;
           else if(COUNT_CLK < 400000 & COUNT_CLK > 350000) LED <= 10'b0111111111;
           else if(COUNT_CLK < 350000 & COUNT_CLK > 300000) LED <= 10'b0011111111;
           else if(COUNT_CLK < 300000 & COUNT_CLK > 250000) LED <= 10'b0001111111;
           else if(COUNT_CLK < 250000 & COUNT_CLK > 200000) LED <= 10'b0000111111;
           else if(COUNT_CLK < 200000 & COUNT_CLK > 150000) LED <= 10'b0000011111;
           else if(COUNT_CLK < 150000 & COUNT_CLK > 100000) LED <= 10'b0000001111;
           else if(COUNT_CLK < 100000 & COUNT_CLK > 50000) LED <= 10'b00000000111;
           else if(COUNT_CLK < 50000 & COUNT_CLK > 0) LED <= 10'b00000000001;
           else LED <= 10'b0000000000;
         end                      
     end
     
     
     function Disp;      //disp函数，用于将0-9的数字转化为段码SEG显示
     input [3:0] x;
     reg [7:0] Seg7;
     begin
       case(x)
         10 : Seg7 = 8'b11111111;
         0 : Seg7 = 8'b00000011;
         1 : Seg7 = 8'b10011111;
         2 : Seg7 = 8'b00100101;
         3 : Seg7 = 8'b00001101;
         4 : Seg7 = 8'b10011001;
         5 : Seg7 = 8'b01001001;
         6 : Seg7 = 8'b01000001;
         7 : Seg7 = 8'b00011111;
         8 : Seg7 = 8'b00000001;
         9 : Seg7 = 8'b00001001;
        endcase
      Disp = (Seg7);
     end
   endfunction
     
     
     always @(posedge CLK1)
       begin
         if(Current_State == WAIT)     //等待状态下，显示____
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
         else if(Current_State == INPUT)  //输入状态下，显示每一位输入的数字
           begin
             if(num >= 4)
               num <= 0;
             else 
               num <= num + 1;
           case(num)
             0:begin
                 AN <= 8'b01111111;
                 SEG <= Disp(Code[3:0]);
               end
             1:begin
                 AN <= 8'b10111111;
                 SEG <= Disp(Code[7:4]);
               end
             2:begin
                 AN <= 8'b11011111;
                 SEG <= Disp(Code[11:8]);
               end 
             3:begin
                 AN <= 8'b11101111;
                 SEG <= Disp(Code[15:12]);
               end
             4:begin
                 AN <= 8'b11111110;
                 SEG <= Disp(Error_Times);
               end                        
             endcase
           end
         
         else if(Current_State == UNLOCK)  //解锁状态下，显示HELLO
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
           
           else if(Current_State == ERROR)    //错误状态下，显示ERROR
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
               
           else if(Current_State == ALARM)   //报警状态下，显示EEEE
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
         
           else if(Current_State == ADMIN)     //管理员修改密码状态下，显示每一位输入的数字
             begin
               if(num >= 3)
                 num <= 0;
               else
                 num <= num + 1;
               case(num)
                 0:begin
                     AN <= 8'b01111111;
                     SEG <= Disp(Code[3:0]);
                   end
                1:begin
                    AN <= 8'b10111111;
                    SEG <= Disp(Code[7:4]);
                  end
                2:begin
                    AN <= 8'b11011111;
                    SEG <= Disp(Code[11:8]);
                  end 
                3:begin
                    AN <= 8'b11101111;
                    SEG <= Disp(Code[15:12]);
                  end                    
               endcase
           end
       end
   
endmodule

