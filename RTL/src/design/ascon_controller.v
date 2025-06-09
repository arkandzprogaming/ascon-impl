`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 05/29/2025 08:06:48 PM
// Design Name: 
// Module Name: ascon_controller
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


module ascon_controller (
        input clk,
        input rstn,
        
        output load_data_in,
        output load_length,
        output done
    );
    
    // -- REGISTERS AND WIRES -- ////////////////
    
    /**/
    
    
    // -- SUB-MODULES -- ////////////////
    
    /**/
    
    
    // -- LOGIC -- ////////////////
     
    always @(posedge clk or negedge rstn) begin
        if (!rstn) begin
            
        end
    end
    
endmodule
