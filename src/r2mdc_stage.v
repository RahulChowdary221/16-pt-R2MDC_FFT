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
    
   
    output reg signed [15:0] dout_top_real,
   output reg signed [15:0] dout_top_imag,
   output reg signed  [15:0]dout_bot_real,
    output reg signed [15:0] dout_bot_imag
);
  wire signed [15:0] delay_out_real, delay_out_imag;

    // --- 1. DELAY LINES (always shifting din_top input) ---
    delay_line #(.DEPTH(STAGE_DELAY)) delay_block_real (
        .clk(clk), .rst(rst),
        .din(din_top_real),
        .dout(delay_out_real)
    );
    delay_line #(.DEPTH(STAGE_DELAY)) delay_block_imag (
        .clk(clk), .rst(rst),
        .din(din_top_imag),
        .dout(delay_out_imag)
    );

    // --- 2. COMMUTATOR (mux selects butterfly inputs) ---
    // sel=0 → fill phase:   butterfly gets delay_out vs 0  (idles)
    // sel=1 → compute phase: butterfly gets din_top vs delay_out (fires)
    wire signed [15:0] bf_top_real = sel ? din_top_real   : delay_out_real;
    wire signed [15:0] bf_top_imag = sel ? din_top_imag   : delay_out_imag;
    wire signed [15:0] bf_bot_real = sel ? delay_out_real : 16'sd0;
    wire signed [15:0] bf_bot_imag = sel ? delay_out_imag : 16'sd0;

    // --- 3. BUTTERFLY ---
    wire signed [15:0] raw_top_real, raw_top_imag;
    wire signed [15:0] raw_bot_real, raw_bot_imag;

    Butterfly_unit My_math_engine (
        .din_top_real(bf_top_real),  .din_top_imag(bf_top_imag),
        .din_bot_real(bf_bot_real),  .din_bot_imag(bf_bot_imag),
        .w_real(w_real),             .w_imag(w_imag),
        .dout_top_real(raw_top_real), .dout_top_imag(raw_top_imag),
        .dout_bot_real(raw_bot_real), .dout_bot_imag(raw_bot_imag)
    );

    // --- 4. OUTPUT PIPELINE REGISTER ---
    // Change output ports from "wire" to "reg" at the top for this to work
    always @(posedge clk) begin
    if (rst) begin
        dout_top_real <= 0; dout_top_imag <= 0;
        dout_bot_real <= 0; dout_bot_imag <= 0;
    end else if (sel) begin
        // COMPUTE phase: pass butterfly results
        dout_top_real <= raw_top_real; dout_top_imag <= raw_top_imag;
        dout_bot_real <= raw_bot_real; dout_bot_imag <= raw_bot_imag;
    end else begin
        // FILL phase: output zeros, butterfly should not propagate
        dout_top_real <= delay_out_real; dout_top_imag <= delay_out_imag;
        dout_bot_real <= 16'sd0;        dout_bot_imag <= 16'sd0;
    end
end
endmodule
    
