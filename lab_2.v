`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2023/08/28 14:54:07
// Design Name: 
// Module Name: lab_2
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


module lab_2(
input [3:0] data_in,
output [7:0] segments,
output [7:0] an
    );
    reg dp, cg, cf, ce, cd, cc, cb, ca;
always @(data_in) begin
        case(data_in)
             4'h0: {ca, cb, cc, cd, ce, cf, cg, dp} = 8'b0000_0011;
             4'h1: {ca, cb, cc, cd, ce, cf, cg, dp} = 8'b1001_1111;
             4'h2: {ca, cb, cc, cd, ce, cf, cg, dp} = 8'b0010_0101;
             4'h3: {ca, cb, cc, cd, ce, cf, cg, dp} = 8'b0000_1101;
             4'h4: {ca, cb, cc, cd, ce, cf, cg, dp} = 8'b1001_1001;
             4'h5: {ca, cb, cc, cd, ce, cf, cg, dp} = 8'b0100_1001;
             4'h6: {ca, cb, cc, cd, ce, cf, cg, dp} = 8'b0100_0001;
             4'h7: {ca, cb, cc, cd, ce, cf, cg, dp} = 8'b0001_1111;
             4'h8: {ca, cb, cc, cd, ce, cf, cg, dp} = 8'b0000_0001;
             4'h9: {ca, cb, cc, cd, ce, cf, cg, dp} = 8'b0000_1001;
             4'ha: {ca, cb, cc, cd, ce, cf, cg, dp} = 8'b0001_0001;
             4'hb: {ca, cb, cc, cd, ce, cf, cg, dp} = 8'b1100_0001;
             4'hc: {ca, cb, cc, cd, ce, cf, cg, dp} = 8'b1110_0101;
             4'hd: {ca, cb, cc, cd, ce, cf, cg, dp} = 8'b1000_0101;
             4'he: {ca, cb, cc, cd, ce, cf, cg, dp} = 8'b0110_0001;
             4'hf: {ca, cb, cc, cd, ce, cf, cg, dp} = 8'b0111_0001;
             default: {ca, cb, cc, cd, ce, cf, cg, dp} = 8'b1111_1111;
         endcase
        end
  assign segments = {dp, cg, cf, ce, cd, cc, cb, ca};
  assign an = 8'b1111_1110;
    
    
endmodule
