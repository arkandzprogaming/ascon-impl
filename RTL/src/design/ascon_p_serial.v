`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 06/18/2025 01:36:23 AM
// Design Name: 
// Module Name: ascon_p_serial
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


module ascon_p_serial
    #(parameter BW = 64) (
        input clk,
        input rstn,
        input en,
        input [2:0] slice_idx,          // controls which state word (0..4) is loaded
        input [7:0] round_const,        
        input [BW-1:0] slice_in,        // one 64-bit word at a time
        output reg [BW-1:0] slice_out
    );

    // Internal state register bank: 5 x 64-bit
    reg [BW-1:0] state [0:4];

    // Stage registers (can be pipelined)
    reg [BW-1:0] S0, S1, S2, S3, S4;
    reg [BW-1:0] T0, T1, T2, T3, T4;
    reg [BW-1:0] sub0, sub1, sub2, sub3, sub4;
    wire [BW-1:0] rot0, rot1, rot2, rot3, rot4;
    reg [BW-1:0] tmp;

    // Round constant injection (only applies to S2)
    always @(posedge clk or negedge rstn) begin
        if (!rstn) begin
            state[0] <= 0; state[1] <= 0; state[2] <= 0;
            state[3] <= 0; state[4] <= 0;
        end else if (en) begin
            state[slice_idx] <= slice_in;
            if (slice_idx == 2)         // inject constant when loading S[2]
                state[2] <= slice_in ^ {{56'd0}, round_const};
        end
    end
    
    // round constant ROM lookup
    // function [7:0] c_r (input integer round);
    //     case (round)
    //         0: c_r = 8'd240; 
    //         1: c_r = 8'd225;
    //         2: c_r = 8'd210;
    //         3: c_r = 8'd195;
    //         4: c_r = 8'd180;
    //         5: c_r = 8'd165;
    //         6: c_r = 8'd150;
    //         7: c_r = 8'd135;
    //         8: c_r = 8'd120;
    //         9: c_r = 8'd105;
    //         10: c_r = 8'd90;
    //         11: c_r = 8'd75;
    //     endcase
    // endfunction

    // Substitution layer
    always @(*) begin
        S0 = state[0];
        S1 = state[1];
        S2 = state[2];
        S3 = state[3];
        S4 = state[4];

        S0 = S0 ^ S4;
        S4 = S4 ^ S3;
        S2 = S2 ^ S1;

        T0 = (~S0) & S1;
        T1 = (~S1) & S2;
        T2 = (~S2) & S3;
        T3 = (~S3) & S4;
        T4 = (~S4) & S0;

        sub0 = S0 ^ T1;
        sub1 = S1 ^ T2;
        sub2 = S2 ^ T3;
        sub3 = S3 ^ T4;
        sub4 = S4 ^ T0;

        sub1 = sub1 ^ sub0;
        sub0 = sub0 ^ sub4;
        sub3 = sub3 ^ sub2;
        sub2 = sub2 ^ {BW{1'b1}}; // inversion
    end

    // Diffusion (ROTR instances)
    rotr ROT0(.val(sub0), .n_1(6'd19), .n_2(6'd28), .out(rot0));
    rotr ROT1(.val(sub1), .n_1(6'd61), .n_2(6'd39), .out(rot1));
    rotr ROT2(.val(sub2), .n_1(6'd1),  .n_2(6'd6),  .out(rot2));
    rotr ROT3(.val(sub3), .n_1(6'd10), .n_2(6'd17), .out(rot3));
    rotr ROT4(.val(sub4), .n_1(6'd7),  .n_2(6'd41), .out(rot4));

    always @(*) begin
        case (slice_idx)
            3'd0: tmp = sub0 ^ rot0;
            3'd1: tmp = sub1 ^ rot1;
            3'd2: tmp = sub2 ^ rot2;
            3'd3: tmp = sub3 ^ rot3;
            3'd4: tmp = sub4 ^ rot4;
            default: tmp = 0;
        endcase
    end
    
    always @(posedge clk or negedge rstn) begin
        if (!rstn)
            slice_out <= 'd0;
        else 
            slice_out <= tmp;
    end

endmodule
