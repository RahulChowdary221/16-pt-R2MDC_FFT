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


`timescale 1ns / 1ps

module fft_control_unit (
    input wire clk,
    input wire rst,
    
    // Commutator Selects (Current State)
    output wire sel1,
    output wire sel2,
    output wire sel3,
    output wire sel4,
    
    // ROM Addresses (Next State / Early Fetch)
    output wire [2:0] rom_addr1,
    output wire [1:0] rom_addr2,
    output wire       rom_addr3,
    output reg dout_valid

);

    reg [3:0] count;
reg [4:0] valid_count;
    
    // 1. The Master Counter
    always @(posedge clk) begin
    if (rst) begin
        count       <= 4'd0;
        valid_count <= 5'd0;
        dout_valid  <= 1'b0;
    end else begin
        count <= count + 1'b1;
        if (valid_count < 5'd19) begin
            valid_count <= valid_count + 1'b1;
            dout_valid  <= 1'b0;
        end else begin
            dout_valid  <= 1'b1;
        end
    end
end
    // ----------------------------------------------------
    // THE FIX: The "Early Fetch" Look-Ahead wire
    // ----------------------------------------------------
    wire [3:0] next_count = count + 1'b1;

    // 2. The Commutators (Combinational)
    // They switch instantly based on the CURRENT cycle
    assign sel1 = count[3]; // Toggles every 8 cycles
    assign sel2 = count[2]; // Toggles every 4 cycles
    assign sel3 = count[1]; // Toggles every 2 cycles
    assign sel4 = count[0]; // Toggles every 1 cycle

    // 3. The Twiddle ROMs (Synchronous)
    // They fetch based on the NEXT cycle, perfectly hiding the 1-cycle BRAM delay
    assign rom_addr1 = next_count[2:0]; 
    assign rom_addr2 = next_count[1:0]; 
    assign rom_addr3 = next_count[0];   

endmodule
