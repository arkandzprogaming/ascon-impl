`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 02/27/2025 11:59:43 AM
// Design Name: 
// Module Name: ascon_p
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


module ascon_p
    # (parameter BW = 64)
    (
        input clk,
        input rstn,
        input [3:0] din,
        input [BW*5 - 1:0] s_in,
        output [BW*5 - 1:0] s_out,
        output [3:0] r,
        output done
    );
    
    // register
//    reg [3:0] r_reg;    // round (< 12)
    reg [BW*5 - 1:0] s_reg;
    reg [BW*5 - 1:0] t_reg;
    reg [BW*5 - 1:0] s_new;
    
    // wire
    wire [3:0] roundw;
    

    round_counter round_ctr (
        .clk(clk),
        .load(!rstn),
        .inc(1'b1),     // Always increment on each clock cycle
        .din(din),
        .dout(roundw),
        .done(done)
    );
    
    
    // combinational permutation "add round constants"
    always @(*) begin
        s_new [BW*5 - 1:BW*3] = s_reg [BW*5 - 1:BW*3];
        s_new [BW*2 - 1:BW*0] = s_reg [BW*2 - 1:BW*0];
        s_new [BW*3 - 1:BW*2] = s_reg [BW*3 - 1:BW*2] ^ (8'hf0 - roundw * 8'h10 + roundw * 8'h01);
    end

    
    always @(posedge clk or negedge rstn) begin
        if (!rstn) begin
            s_reg <= s_in;  // Let the effect of s_in be stuck at !rstn
            t_reg <= 320'h0;
//            r_reg <= 4'h0;
        end else begin
            s_reg <= s_new; // Update state with the previous-cycle computed value
//            r_reg <= r_reg + 1;
        end
                                                 
        // substitution layer
//        s_reg [BW*5 - 1:BW*4] <= s_reg [BW*5 - 1:BW*4] ^ s_reg [BW*1 - 1:BW*0];
//        s_reg [BW*1 - 1:BW*0] <= s_reg [BW*1 - 1:BW*0] ^ s_reg [BW*2 - 1:BW*1];
//        s_reg [BW*3 - 1:BW*2] <= s_reg [BW*3 - 1:BW*2] ^ s_reg [BW*4 - 1:BW*3];
        
//        t_reg [BW*5 - 1:4] <= (~s_reg [BW*5 - 1:BW*4]) & s_reg [BW*4 - 1:BW*3];
//        t_reg [BW*4 - 1:3] <= (~s_reg [BW*4 - 1:BW*3]) & s_reg [BW*3 - 1:BW*2];
//        t_reg [BW*3 - 1:2] <= (~s_reg [BW*3 - 1:BW*2]) & s_reg [BW*2 - 1:BW*1];
//        t_reg [BW*2 - 1:1] <= (~s_reg [BW*2 - 1:BW*1]) & s_reg [BW*1 - 1:BW*0];
//        t_reg [BW*1 - 1:0] <= (~s_reg [BW*1 - 1:BW*0]) & s_reg [BW*5 - 1:BW*4];
    end
    
    // output
    assign s_out = s_reg;
    assign r = roundw;
    
    
endmodule
