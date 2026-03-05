`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 27.02.2026 11:07:40
// Design Name: 
// Module Name: Adder_subtractor
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


module Adder_subtractor(input wire signed [15:0] a_real,a_imag,
b_real,b_imag,
output wire signed [16:0] sum_real,sum_imag,
output wire signed [16:0] diff_real,diff_imag
    );
 
 
assign sum_real = a_real + b_real;
assign sum_imag = a_imag + b_imag;
assign diff_real = a_real - b_real;
assign diff_imag = a_imag - b_imag;
endmodule


   
