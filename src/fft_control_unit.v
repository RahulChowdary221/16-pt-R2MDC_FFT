`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 01.03.2026 07:23:19
// Design Name: 
// Module Name: fft_control_unit
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


module fft_control_unit(input clk,rst,output reg [3:0] cout
    );
    always@(posedge clk)
    begin
    if(rst)
    cout<=0;
    else 
    cout<= cout+1;
    end
    
endmodule
