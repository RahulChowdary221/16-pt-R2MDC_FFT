

module fft_16_top(
    input clk,
    input rst,
    input wire signed [15:0] din_real,
    input wire signed [15:0] din_imag,

    output wire signed [15:0] dout_top_real,
    output wire signed [15:0] dout_top_imag,
    output wire signed [15:0] dout_bot_real,
    output wire signed [15:0] dout_bot_imag,
     output wire dout_valid
);
    
   // --- 1. Internal Wires & Control Unit ---
    wire signed [15:0] stg1_top_real, stg1_top_imag, stg1_bot_real, stg1_bot_imag;
    wire signed [15:0] stg2_top_real, stg2_top_imag, stg2_bot_real, stg2_bot_imag;
    wire signed [15:0] stg3_top_real, stg3_top_imag, stg3_bot_real, stg3_bot_imag;

    // NEW: The split wires from our updated Early-Fetch Control Unit
    wire sel1, sel2, sel3, sel4;
    wire [2:0] rom_addr1;
    wire [1:0] rom_addr2;
    wire       rom_addr3;


fft_control_unit master_ctrl(
    .clk(clk),
    .rst(rst),
    .sel1(sel1), .sel2(sel2), .sel3(sel3), .sel4(sel4),
    .rom_addr1(rom_addr1), .rom_addr2(rom_addr2), .rom_addr3(rom_addr3),
    .dout_valid(dout_valid)

    );

    // --- 2. Twiddle ROM Wires & Instantiations ---
    
    // Stage 1 ROM (Uses the Early-Fetch Address!)
    wire [31:0] s1_twiddle_data;
    wire signed [15:0] w1_real, w1_imag;
    stage1_rom rom1 (
        .clka(clk),    
        .addra(rom_addr1), // <--- UPDATED
        .douta(s1_twiddle_data)
    );
    assign w1_real = s1_twiddle_data[31:16];
    assign w1_imag = s1_twiddle_data[15:0];

    // Stage 2 ROM 
    wire [31:0] s2_twiddle_data;
    wire signed [15:0] w2_real, w2_imag;
    stage_2_rom rom2(
        .clka(clk),
        .addra(rom_addr2), // <--- UPDATED
        .douta(s2_twiddle_data)
    );
    assign w2_real = s2_twiddle_data[31:16];
    assign w2_imag = s2_twiddle_data[15:0];

    // Stage 3 ROM
    wire [31:0] s3_twiddle_data;
    wire signed [15:0] w3_real, w3_imag;
    stage3_rom rom3(
        .clka(clk),
        .addra(rom_addr3), // <--- UPDATED
        .douta(s3_twiddle_data)
    );
    assign w3_real = s3_twiddle_data[31:16];
    assign w3_imag = s3_twiddle_data[15:0];

    // --- 3. FFT Stages ---

    r2mdc_stage #( .STAGE_DELAY(8)) fft_stage1(
        .clk(clk),
        .rst(rst),
        .sel(sel1), // <--- UPDATED
        .w_real(w1_real), .w_imag(w1_imag),
        .din_top_real(din_real), .din_top_imag(din_imag),
        .din_bot_real(16'sd0), .din_bot_imag(16'sd0),
        .dout_top_real(stg1_top_real), .dout_top_imag(stg1_top_imag),
        .dout_bot_real(stg1_bot_real), .dout_bot_imag(stg1_bot_imag)
    );

    r2mdc_stage #(.STAGE_DELAY(4)) fft_stage2(
        .clk(clk),
        .rst(rst),
        .sel(sel2), // <--- UPDATED
        .w_real(w2_real), .w_imag(w2_imag),
        .din_top_real(stg1_top_real), .din_top_imag(stg1_top_imag),
        .din_bot_real(stg1_bot_real), .din_bot_imag(stg1_bot_imag),
        .dout_top_real(stg2_top_real), .dout_top_imag(stg2_top_imag),
        .dout_bot_real(stg2_bot_real), .dout_bot_imag(stg2_bot_imag)
    );

    r2mdc_stage #(.STAGE_DELAY(2)) fft_stage3(
        .clk(clk),
        .rst(rst),
        .sel(sel3), // <--- UPDATED
        .w_real(w3_real), .w_imag(w3_imag),
        .din_top_real(stg2_top_real), .din_top_imag(stg2_top_imag),
        .din_bot_real(stg2_bot_real), .din_bot_imag(stg2_bot_imag),
        .dout_top_real(stg3_top_real), .dout_top_imag(stg3_top_imag),
        .dout_bot_real(stg3_bot_real), .dout_bot_imag(stg3_bot_imag)
    );

    r2mdc_stage #(.STAGE_DELAY(1)) fft_stage4(
        .clk(clk),
        .rst(rst),
        .sel(sel4), // <--- UPDATED
        .w_real(16'h7FFF), .w_imag(16'h0000), 
        .din_top_real(stg3_top_real), .din_top_imag(stg3_top_imag),
        .din_bot_real(stg3_bot_real), .din_bot_imag(stg3_bot_imag),
        .dout_top_real(dout_top_real), 
        .dout_top_imag(dout_top_imag),
        .dout_bot_real(dout_bot_real), 
        .dout_bot_imag(dout_bot_imag)
    );

endmodule
