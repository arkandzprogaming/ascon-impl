`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 03/30/2025 11:46:06 AM
// Design Name: 
// Module Name: round_counter
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


module round_counter (
    input clk,              // Clock signal
    input load,             // Load enable signal
    input inc,              // Increment enable signal
    input [3:0] din,        // Load value
    output reg [3:0] dout,  // Current round count
    output reg done         // Stop signal when count reaches 12
);
    
    always @(posedge clk) begin
        if (load) begin
            dout <= din;        // Load initial value
            done <= 0;
        end
        else if (inc && !done) begin
            dout <= dout + 1;   // Increment count
            if (dout == 4'd11)  // When reaching 12 rounds
                done <= 1;
        end
    end

endmodule

