`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 02/23/2025 11:28:43 AM
// Design Name: 
// Module Name: rotr
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


module rotr
    #(parameter BW = 64)
    (
        input clk,
        input rstn,
        input [BW - 1:0] val,    // input to be rotated
        input [5:0] n_1,         // number of rotation up to 63
        input [5:0] n_2,         // number of rotation up to 63
        output [BW - 1:0] out
    );
    
    assign out = ((val >> n_1) | (val << (BW - n_1))) ^ ((val >> n_2) | (val << (BW - n_2)));
    
endmodule
