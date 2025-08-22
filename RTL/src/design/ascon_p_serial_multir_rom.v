`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 06/27/2025 08:55:55 PM
// Design Name: 
// Module Name: ascon_p_serial_multiround
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: Like ascon_p_serial, but supports multiple rounds using a round counter module.
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module ascon_p_serial_multiround    // Using ROM
     #(parameter BW = 64) (
         input clk,
         input rstn,
         input en,                       // Enable for serially loading the initial state
         input en_inc,                   // Enable to start the 12-round permutation
         input [2:0] slice_idx,          // Selects which slice to load/read
         input [BW-1:0] slice_in,        // 64-bit input slice
         output reg [BW-1:0] slice_out,  // 64-bit output slice
         output [3:0] r,                 // Monitor for the current round
         output done                     // Asserted when 12 rounds are complete
     );

    //================================================================
    // REGISTERS AND WIRES
    //================================================================
    
    // Internal state register bank: 5 x 64-bit
    reg [BW-1:0] state [0:4];
    
    // Wire for the current round number from the counter
    wire [3:0] round;

    // Wires for the full 320-bit permuted state, calculated combinationally
    wire [BW*5 - 1:0] next_state_w;


    //================================================================
    // MAIN STATE UPDATE LOGIC (THE CORE FIX)
    //================================================================
    
    // Handles serial input slice when en = 1
    // Handles multi-round permutation input state when en_inc = 1
    always @(posedge clk or negedge rstn) begin
        if (!rstn) begin
            state[0] <= 0; state[1] <= 0; state[2] <= 0;
            state[3] <= 0; state[4] <= 0;
        end else if (en) begin
            state[slice_idx] <= slice_in;
        end 
        // Internal permutation. This is the new feedback path.
        // On each clock cycle, the state is updated with the permuted version of itself.
        else if (en_inc && !done) begin
            {state[0], state[1], state[2], state[3], state[4]} <= next_state_w;
        end
    end


    //================================================================
    // COMBINATIONAL PERMUTATION LOGIC (INTERNAL PARALLEL DATAPATH)
    //================================================================
    
    // This logic is now similar to the parallel ascon_p_core.
    // It calculates the full 320-bit next_state_w based on the current state.
    
    // Intermediate wires for the permutation layers
    wire [BW-1:0] s_rc0, s_rc1, s_rc2, s_rc3, s_rc4;
    wire [BW-1:0] s_p1_0, s_p1_1, s_p1_2, s_p1_3, s_p1_4;
    wire [BW-1:0] t0, t1, t2, t3, t4;
    wire [BW-1:0] s_p2_0, s_p2_1, s_p2_2, s_p2_3, s_p2_4;
    wire [BW-1:0] s_sub_0, s_sub_1, s_sub_2, s_sub_3, s_sub_4;
    wire [BW-1:0] s_q0, s_q1, s_q2, s_q3, s_q4;
    wire [BW-1:0] s_ld_0, s_ld_1, s_ld_2, s_ld_3, s_ld_4;

    // Layer 1: Add Round Constant
    // The constant is XORed with the current state[2]
    assign s_rc0 = state[0];
    assign s_rc1 = state[1];
    assign s_rc2 = state[2] ^ {{56'd0}, c_r(round)}; // Uses current round from counter
    assign s_rc3 = state[3];
    assign s_rc4 = state[4];

    // Layer 2: Substitution Layer (S-box)
    assign s_p1_0 = s_rc0 ^ s_rc4;
    assign s_p1_4 = s_rc4 ^ s_rc3;
    assign s_p1_2 = s_rc2 ^ s_rc1;
    assign s_p1_1 = s_rc1;
    assign s_p1_3 = s_rc3;
    
    assign t0 = (~s_p1_0) & s_p1_1;
    assign t1 = (~s_p1_1) & s_p1_2;
    assign t2 = (~s_p1_2) & s_p1_3;
    assign t3 = (~s_p1_3) & s_p1_4;
    assign t4 = (~s_p1_4) & s_p1_0;
    
    assign s_p2_0 = s_p1_0 ^ t1;
    assign s_p2_1 = s_p1_1 ^ t2;
    assign s_p2_2 = s_p1_2 ^ t3;
    assign s_p2_3 = s_p1_3 ^ t4;
    assign s_p2_4 = s_p1_4 ^ t0;
    
    assign s_sub_1 = s_p2_1 ^ s_p2_0;
    assign s_sub_0 = s_p2_0 ^ s_p2_4;
    assign s_sub_3 = s_p2_3 ^ s_p2_2;
    assign s_sub_2 = s_p2_2 ^ {BW{1'b1}};
    assign s_sub_4 = s_p2_4;

    // Layer 3: Linear Diffusion Layer
    assign s_ld_0 = s_sub_0 ^ s_q0;
    assign s_ld_1 = s_sub_1 ^ s_q1;
    assign s_ld_2 = s_sub_2 ^ s_q2;
    assign s_ld_3 = s_sub_3 ^ s_q3;
    assign s_ld_4 = s_sub_4 ^ s_q4;
    
    // Final 320-bit result of the permutation
    assign next_state_w = {s_ld_0, s_ld_1, s_ld_2, s_ld_3, s_ld_4};


    //================================================================
    // OUTPUT LOGIC
    //================================================================
    
    // This MUX selects a slice from the final state for serial reading.
    // It is controlled by the external slice_idx.
    reg [BW-1:0] tmp_out;
    always @(*) begin
        case (slice_idx)
            3'd0: tmp_out = state[0];
            3'd1: tmp_out = state[1];
            3'd2: tmp_out = state[2];
            3'd3: tmp_out = state[3];
            3'd4: tmp_out = state[4];
            default: tmp_out = 0;
        endcase
    end
    
    // The output port is registered for better timing.
    always @(posedge clk or negedge rstn) begin
        if (!rstn)
            slice_out <= 'd0;
        else 
            slice_out <= tmp_out;
    end


    //================================================================
    // SUB-MODULES
    //================================================================
    
    // Round constant ROM lookup function
    function [7:0] c_r (input integer round);
        case (round)
            0: c_r = 8'hF0; 1: c_r = 8'hE1; 2: c_r = 8'hD2; 3: c_r = 8'hC3;
            4: c_r = 8'hB4; 5: c_r = 8'hA5; 6: c_r = 8'h96; 7: c_r = 8'h87;
            8: c_r = 8'h78; 9: c_r = 8'h69; 10: c_r = 8'h5A; 11: c_r = 8'h4B;
            default: c_r = 8'h00;
        endcase
    endfunction

    // Round counter instance
    round_counter round_ctr (
        .clk(clk),
        .load(!rstn),
        .inc(en_inc),
        .dout(round),
        .done(done)
    );
    
    // ROTR instances
    rotr ROT0(.val(s_sub_0), .n_1(19), .n_2(28), .out(s_q0));
    rotr ROT1(.val(s_sub_1), .n_1(61), .n_2(39), .out(s_q1));
    rotr ROT2(.val(s_sub_2), .n_1(1),  .n_2(6),  .out(s_q2));
    rotr ROT3(.val(s_sub_3), .n_1(10), .n_2(17), .out(s_q3));
    rotr ROT4(.val(s_sub_4), .n_1(7),  .n_2(41), .out(s_q4));

    assign r = round; // Output the current round count for monitoring
endmodule
