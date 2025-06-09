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
        
        input [BW - 1:0] new_block,
        input [7:0] m_length,
        
        output reg [BW*4 - 1:0] hash_tag,
        output reg hash_done
    );
    
    // -- REGISTERS AND WIRES -- ////////////////
    
    reg [7:0] count_m_length;   // counts each new block in 8-byte multiples (bytes)
    reg [7:0] length_reg;       // expected input message length
    
    reg [BW - 1:0] new_block_reg;
    reg [7:0] m_length_reg;
    
    
    // -- SUB-MODULES -- ////////////////
    
    /**/
    
    
    // -- LOGIC -- ////////////////
    
    /**/
    
endmodule
