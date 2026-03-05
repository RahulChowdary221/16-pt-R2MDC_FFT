`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 28.02.2026 07:39:48
// Design Name: 
// Module Name: delay_line
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


module delay_line #(parameter DEPTH = 8) (
    input clk,
    input rst, // MAKE SURE RST IS CONNECTED!
    input signed [15:0] din,
    output signed [15:0] dout
);
    reg signed [15:0] shift_reg [0:DEPTH-1];
    integer i;

    always @(posedge clk) begin
        if (rst) begin
            // Clear the memory to zero during reset
            for (i = 0; i < DEPTH; i = i + 1) begin
                shift_reg[i] <= 16'd0;
            end
        end else begin
            // Shift data
            shift_reg[0] <= din;
            for (i = 1; i < DEPTH; i = i + 1) begin
                shift_reg[i] <= shift_reg[i-1];
            end
        end
    end

    assign dout = shift_reg[DEPTH-1];
endmodule
