`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 06/14/2025 08:12:32 AM
// Design Name: 
// Module Name: ascon_p_core
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


module ascon_p_core    
    # (parameter BW = 64)
    (
        input clk,
        input rstn,
        input [7:0] round_const,
        input [BW*5 - 1:0] s_in,
        
        output reg [BW*5 - 1:0] s_out
    );
    
    // -- REGISTERS AND WIRES -- ////////////////
    
    reg [BW*5-1:0] s_reg;
    reg [7:0] c_r_reg;           // Current round constant input
    
    always @(posedge clk or negedge rstn) begin
        if (!rstn) begin
            c_r_reg <= 0;
            s_reg <= 0;      // Let the effect of s_in be stuck at !rstn
        end else begin
            c_r_reg <= round_const;
            s_reg <= s_in;   // Start s_in
        end
    end 
    
    // Wire for "add round constants" layer
    wire [BW-1:0] s_rc0; // MSB word
    wire [BW-1:0] s_rc1;
    wire [BW-1:0] s_rc2;
    wire [BW-1:0] s_rc3;
    wire [BW-1:0] s_rc4; // LSB word
    
    // Intermediate registers for substitution steps
    reg [BW-1:0] s_p1_0, s_p1_1, s_p1_2, s_p1_3, s_p1_4;   // First XORs of sub_layer
    reg [BW-1:0] t0, t1, t2, t3, t4;                       // T words
    reg [BW-1:0] s_p2_0, s_p2_1, s_p2_2, s_p2_3, s_p2_4;   // After S[i] ^= T[(i+1)%5] (T word assignment)
    
    // Last XORs of sub_layer (input to "linear diffusion" layer)
    reg [BW-1:0] s_sub_0, s_sub_1, s_sub_2, s_sub_3, s_sub_4;
    
    // Intermediate registers for linear diffusion steps
    wire [BW-1:0] s_q0, s_q1, s_q2, s_q3, s_q4;
    
    // Registers after linear diffusion ROTR
    reg [BW-1:0] s_ld_0, s_ld_1, s_ld_2, s_ld_3, s_ld_4;
    
    // Additional wires and registers
    wire [BW*5-1:0] s_from_sub; // Output of substitution layer
    wire [BW*5-1:0] s_from_ld;  // Output of linear diffusion layer
    
    
    // -- SUB-MODULES -- ////////////////
    
    // ROTR instances
    rotr rot_q0 (
        .val(s_sub_0),
        .n_1(6'd19),
        .n_2(6'd28),
        .out(s_q0)
    ); rotr rot_q1 (
        .val(s_sub_1),
        .n_1(6'd61),
        .n_2(6'd39),
        .out(s_q1)
    ); rotr rot_q2 (
        .val(s_sub_2),
        .n_1(6'd1),
        .n_2(6'd6),
        .out(s_q2)
    ); rotr rot_q3 (
        .val(s_sub_3),
        .n_1(6'd10),
        .n_2(6'd17),
        .out(s_q3)
    ); rotr rot_q4 (
        .val(s_sub_4),
        .n_1(6'd7),
        .n_2(6'd41),
        .out(s_q4)
    );
    
    
    // -- LOGIC -- ////////////////
    
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
    
    // combinational permutation "add round constants"
    assign s_rc0 = s_reg [BW*5 - 1:BW*4];
    assign s_rc1 = s_reg [BW*4 - 1:BW*3];
    assign s_rc2 = s_reg [BW*3 - 1:BW*2] ^ {{56'd0}, c_r_reg};
    assign s_rc3 = s_reg [BW*2 - 1:BW*1];
    assign s_rc4 = s_reg [BW*1 - 1:BW*0];
    
    // combinational permutation "substitution layer"
    always @(*) begin
        s_p1_0 = s_rc0 ^ s_rc4;
        s_p1_4 = s_rc4 ^ s_rc3;
        s_p1_2 = s_rc2 ^ s_rc1;
        s_p1_1 = s_rc1;
        s_p1_3 = s_rc3;
        
        t0 = (~s_p1_0) & s_p1_1; // T[0] = (~S'[0]) & S'[1]
        t1 = (~s_p1_1) & s_p1_2; // T[1] = (~S'[1]) & S'[2]
        t2 = (~s_p1_2) & s_p1_3; // T[2] = (~S'[2]) & S'[3]
        t3 = (~s_p1_3) & s_p1_4; // T[3] = (~S'[3]) & S'[4]
        t4 = (~s_p1_4) & s_p1_0; // T[4] = (~S'[4]) & S'[0]
        
        s_p2_0 = s_p1_0 ^ t1; // S''[0] = S'[0] ^ T[1]
        s_p2_1 = s_p1_1 ^ t2; // S''[1] = S'[1] ^ T[2]
        s_p2_2 = s_p1_2 ^ t3; // S''[2] = S'[2] ^ T[3]
        s_p2_3 = s_p1_3 ^ t4; // S''[3] = S'[3] ^ T[4]
        s_p2_4 = s_p1_4 ^ t0; // S''[4] = S'[4] ^ T[0]
        
        s_sub_1 = s_p2_1 ^ s_p2_0;
        s_sub_0 = s_p2_0 ^ s_p2_4;
        s_sub_3 = s_p2_3 ^ s_p2_2;
        s_sub_2 = s_p2_2 ^ {BW{1'b1}};
        s_sub_4 = s_p2_4;
    
        // combinational permutation "linear diffusion layer"        
        s_ld_0 = s_sub_0 ^ s_q0;
        s_ld_1 = s_sub_1 ^ s_q1;
        s_ld_2 = s_sub_2 ^ s_q2;
        s_ld_3 = s_sub_3 ^ s_q3;
        s_ld_4 = s_sub_4 ^ s_q4;
    end
 
     assign s_from_ld = {s_ld_0, s_ld_1, s_ld_2, s_ld_3, s_ld_4};
        
        always @(posedge clk or negedge rstn) begin
            if (!rstn) begin
                s_out <= 0;
            end else begin
                s_out <= s_from_ld;
            end
        end 
        
    endmodule
