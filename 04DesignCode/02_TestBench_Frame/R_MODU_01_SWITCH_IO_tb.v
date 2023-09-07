`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2023/09/07 11:34:43
// Design Name: 
// Module Name: R_MODU_01_SWITCH_IO_tb
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


module R_MODU_01_SWITCH_IO_tb();
// SWITCH_IO Parameters
parameter PERIOD = 10;
parameter Byte  = 4;
parameter Up    = 1;
parameter Down  = 0;

// SWITCH_IO Inputs
reg   RESET                                = 0 ;
reg   [9:0]  SW                            = 0 ;
reg   [9:0]  SW_History                    = 0 ;

// SWITCH_IO Outputs
wire  [7:0]  Up_Queue                      ;
wire  [9:0]  SW_History_Out                ;
wire  [15:0]  Code                         ;
wire  [2:0]  Code_Bit                      ;


initial
begin
    forever #(PERIOD/2)  clk=~clk;
end

initial
begin
    #(PERIOD*2) rst_n  =  1;
end

SWITCH_IO #(
    .Byte ( Byte ),
    .Up   ( Up   ),
    .Down ( Down ))
 u_SWITCH_IO (
    .RESET                   ( RESET                  ),
    .SW                      ( SW              [9:0]  ),
    .SW_History              ( SW_History      [9:0]  ),

    .Up_Queue                ( Up_Queue        [7:0]  ),
    .SW_History_Out          ( SW_History_Out  [9:0]  ),
    .Code                    ( Code            [15:0] ),
    .Code_Bit                ( Code_Bit        [2:0]  )
);

endmodule
