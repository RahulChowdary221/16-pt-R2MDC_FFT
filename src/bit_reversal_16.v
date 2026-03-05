`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 01.03.2026 15:57:37
// Design Name: 
// Module Name: bit_reversal_16
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


module bit_reversal_16(
    input clk,
    input rst,
    input signed [15:0] din_real,
    input signed [15:0] din_imag,
    input [3:0] write_addr, // Use your master count
    output reg signed [15:0] dout_real,
    output reg signed [15:0] dout_imag
);
    // Internal Memory (16 entries)
    reg signed [15:0] mem_real [0:15];
    reg signed [15:0] mem_imag [0:15];

    // Bit-Reverse the Address: {bit0, bit1, bit2, bit3}
    wire [3:0] rev_addr = {write_addr[0], write_addr[1], write_addr[2], write_addr[3]};

    always @(posedge clk) begin
        if (!rst) begin
            // 1. Write the scrambled data coming from the FFT
            mem_real[write_addr] <= din_real;
            mem_imag[write_addr] <= din_imag;

            // 2. Read the data using the REVERSED address
            dout_real <= mem_real[rev_addr];
            dout_imag <= mem_imag[rev_addr];
        end
    end
endmodule
