`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 27.02.2026 11:09:57
// Design Name: 
// Module Name: complex_multiplier
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


module complex_multiplier(input wire signed [15:0] a_real,a_imag,
b_real , b_imag,
output wire signed [32:0] res_real,res_imag
    );
 wire signed [31:0] m1;
 wire signed [31:0] m2;
 wire signed [31:0] m3;
 wire signed [31:0] m4; 
 assign m1 = a_real * b_real;
 assign m2 = a_imag * b_imag;
 assign m3 = a_real * b_imag;
 assign m4 = a_imag * b_real;
 assign res_real = m1 - m2;
 assign res_imag = m3 + m4 ;
 
endmodule


