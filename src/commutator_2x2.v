`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 01.03.2026 09:19:51
// Design Name: 
// Module Name: commutator_2x2
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


module commutator_2x2(
input sel,
input signed [15:0] in_top,
input signed [15:0] in_bot,
output signed [15:0] out_top,
output signed [15:0] out_bot

    );
    assign out_top = sel ? in_bot : in_top;
    assign out_bot = sel ? in_top : in_bot;
endmodule
