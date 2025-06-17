`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 06/03/2025 11:09:13 AM
// Design Name: 
// Module Name: ascon_datapath
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


module ascon_datapath 
    # (parameter BW = 64)
    (
        input clk,
        input rstn,
        input start,
        
        // Message absorption phase
        input [BW - 1:0] new_block,
        input [8:0] last,
        
        // Permutation debug
        output [3:0] r,     // Permutation round debug
        output done,        // Done signal
        
        // Tag squeezing phase
        output reg [BW*4 - 1:0] hash_tag,
        output reg hash_done
    );
    
    // -- REGISTERS AND WIRES -- ////////////////
    
    // Message absorption-related
    reg [BW - 1:0] new_block_reg;
    reg [8:0] last_reg;
    
    // Permutation
    reg [BW*5 - 1:0] s_in_reg;
    wire [BW*5 - 1:0] s_out_wire;
    
    // -- SUB-MODULES -- ////////////////
    
    permutation #(
        .BW(BW)
    ) ascon_p (
        .clk(clk),
        .rstn(rstn),
        .s_in(s_in_reg),
        
        .s_out(s_out_wire),
        .r(r_wire),
        .done(r_done)
    );
    
    
    // -- LOGIC -- ////////////////
    
    /**/
    
endmodule
