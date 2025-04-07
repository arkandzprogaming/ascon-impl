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
        input [5:0] n,           // number of rotation up to 63
        output [BW - 1:0] out
    );
    
    // register input
    reg [BW - 1:0] val_reg;
    reg [5:0] n_reg;
    
    always @(posedge clk or negedge rstn) begin
        if (!rstn) begin
            val_reg <= 0;
            n_reg <= 0;
        end else begin
            val_reg <= val;
            n_reg <= n;
        end
    end
    
    assign out = (val >> n) | (val << (BW - n));
    
endmodule
