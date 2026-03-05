module Butterfly_unit (
    input signed [15:0] din_top_real,
    input signed [15:0] din_top_imag,
    input signed [15:0] din_bot_real,
    input signed [15:0] din_bot_imag,
    input signed [15:0] w_real,
    input signed [15:0] w_imag,
    output signed [15:0] dout_top_real,
    output signed [15:0] dout_top_imag,
    output signed [15:0] dout_bot_real,
    output signed [15:0] dout_bot_imag
);

    // --- STEP 1: ADD/SUB WITH SIGN EXTENSION AND SCALING (/2) ---
    // Extend to 17 bits to prevent overflow during addition
    wire signed [16:0] sum_real  = $signed(din_top_real) + $signed(din_bot_real);
    wire signed [16:0] sum_imag  = $signed(din_top_imag) + $signed(din_bot_imag);
    wire signed [16:0] diff_real = $signed(din_top_real) - $signed(din_bot_real);
    wire signed [16:0] diff_imag = $signed(din_top_imag) - $signed(din_bot_imag);

    // Shift right by 1 to scale back to 16 bits
    wire signed [15:0] top_r = sum_real[16:1];
    wire signed [15:0] top_i = sum_imag[16:1];
    wire signed [15:0] bot_r = diff_real[16:1];
    wire signed [15:0] bot_i = diff_imag[16:1];

    // The top outputs do not get multiplied by the twiddle factor in DIF
    assign dout_top_real = top_r;
    assign dout_top_imag = top_i;


    // --- STEP 2: COMPLEX MULTIPLICATION FOR THE BOTTOM PATH ---
    // (A + jB) * (C + jD) = (AC - BD) + j(AD + BC)
    wire signed [31:0] AC = bot_r * w_real;
    wire signed [31:0] BD = bot_i * w_imag;
    wire signed [31:0] AD = bot_r * w_imag;
    wire signed [31:0] BC = bot_i * w_real;

    wire signed [31:0] mult_real = AC - BD;
    wire signed [31:0] mult_imag = AD + BC;


  
    assign dout_bot_real = mult_real[30:15];
    assign dout_bot_imag = mult_imag[30:15];

endmodule