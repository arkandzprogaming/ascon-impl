`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 05/29/2025 10:59:46 PM
// Design Name: 
// Module Name: top
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


module top
    # (parameter BW = 64)
    (
        input clk,
        input rstn,
        input start,
        
        // input message pre-processing
        input [BW - 1:0] block_in,      // Input message of 8-byte block
        input [8:0] last,               // Last signal to indicate last message byte
        
        // tag squeezing
        output reg [BW*4 - 1:0] hash_tag,   // 256-bit hash tag
        output reg hash_done,
        
        
        // Permutation debug
        output [3:0] permu_r,   // Current round of each permutation instance
        output permu_done       // Done signal of each permutation instance
    );
    
    // -- REGISTERS AND WIRES -- ////////////////
    
    wire load_block;    // Load new block into du register
    wire en_hashtag;    // Enable hash_tag output wiring to top
    
    
    // -- SUB-MODULES -- ////////////////
    
    ascon_controller cu (
        // input from top
        .clk(clk),
        .rstn(rstn),
        .start(start),
        
        // wired to du
        .load_block(load_block),
        .en_hashtag(en_hashtag)
    );
    
    ascon_datapath du (
        // input from top
        .clk(clk),
        .rstn(rstn),
        .start(start),
        .new_block(block_in),
        .last(last),
        
        // wired from cu
        .load_block(load_block),
        .en_hashtag(en_hashtag),
        
        // output to top
        .hash_tag(hash_tag),
        .hash_done(hash_done)
    );
    
endmodule

