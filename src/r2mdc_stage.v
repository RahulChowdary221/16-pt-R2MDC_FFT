`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 28.02.2026 09:26:08
// Design Name: 
// Module Name: r2mdc_stage
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


module r2mdc_stage #(parameter STAGE_DELAY = 8) (
  
    input wire clk,
    input wire sel,
    input wire rst,
    
    
   input signed [15:0] din_top_real,
    input signed [15:0] din_top_imag,
    input signed [15:0] din_bot_real,
    input signed [15:0] din_bot_imag,
    
    
    input wire signed [15:0] w_real,
    input wire signed [15:0] w_imag,
    
   
    output wire signed [15:0] dout_top_real,
   output wire signed [15:0] dout_top_imag,
   output wire signed  [15:0]dout_bot_real,
    output wire signed [15:0] dout_bot_imag
);
 wire signed [15:0] delayed_real;
 wire signed [15:0] delayed_imag;
 
wire signed [15:0] comm_out_top_real, comm_out_top_imag;
wire signed [15:0] comm_out_bot_real, comm_out_bot_imag;
   //delay block , we have complex numbers of imag and real ,so declare real and imag
// 1. THE COMMUTATORS (Lane Switchers)
    // These handle the criss-cross logic for Real and Imaginary paths
    commutator_2x2 comm_real (
        .sel(sel),
        .in_top(din_top_real),
        .in_bot(din_bot_real),
        .out_top(comm_out_top_real),
        .out_bot(comm_out_bot_real)
    );

    commutator_2x2 comm_imag (
        .sel(sel),
        .in_top(din_top_imag),
        .in_bot(din_bot_imag),
        .out_top(comm_out_top_imag),
        .out_bot(comm_out_bot_imag)
    );

    // 2. THE DELAY LINES (Waiting Room)
    // We only delay the BOTTOM path from the commutator
    delay_line #(.DEPTH(STAGE_DELAY)) delay_block_real (
        .clk(clk),
        .rst(rst),
        .din(comm_out_bot_real), // Take data from the commutator bot exit
        .dout(delayed_real)
    );

    delay_line #(.DEPTH(STAGE_DELAY)) delay_block_imag (
        .clk(clk),
        .din(comm_out_bot_imag),
        .dout(delayed_imag),
        .rst(rst)
    );

    // 3. THE BUTTERFLY UNIT (Math Engine)
    // 3. THE BUTTERFLY UNIT (Math Engine)
    Butterfly_unit My_math_engine(
        // Inputs: 'top' bypasses delay, 'bot' comes from delay line
        .din_top_real(comm_out_top_real),
        .din_top_imag(comm_out_top_imag),
        .din_bot_real(delayed_real),
        .din_bot_imag(delayed_imag),
        
        // Twiddle Factors
        .w_real(w_real),
        .w_imag(w_imag),
        
        // Outputs mapped directly to the stage's exit pins
        .dout_top_real(dout_top_real),
        .dout_top_imag(dout_top_imag),
        .dout_bot_real(dout_bot_real),
        .dout_bot_imag(dout_bot_imag)
    );
endmodule
    
