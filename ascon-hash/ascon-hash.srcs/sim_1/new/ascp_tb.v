`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 03/17/2025 08:59:02 AM
// Design Name: 
// Module Name: ascp_tb
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


module ascp_tb();
    parameter BW = 64;
    parameter DIN = 0;
    
    // input
    reg clk;
    reg rstn;
    reg [3:0] din;
    reg [BW*5 - 1:0] s_in;
    
    // output
    wire [BW*5 - 1:0] s_out;
    wire [3:0] r;   // For monitoring purposes
    wire done;
    
    ascon_p #(BW) uut(
        .clk(clk),
        .rstn(rstn),
        .din(din),
        .s_in(s_in),
        .s_out(s_out),
        .r(r),
        .done(done)
    );
    
    // signal generator
    always #2 clk = ~clk;
    
    initial begin
        // Initialize signals
        clk = 1;
        rstn = 0;   // Counter loads initial value (load == !rstn)
        din = DIN;  // Initial load value for counter
        
        // State initial value
        s_in = {64'h00400C0000000100, 256'h0};
        
        // Reset sequence
        #4 rstn = 1;
        
        // End simulation
        forever begin
            @(posedge clk);
            if (done) begin
                $display("Completed 12 rounds at time %t", $time);
                $finish; // Delay last iteration for a whole cycle before finishing
            end
        end
    end
    
    // Monitor in console
    initial begin
        $monitor($time, " s_in = %h, r = %d, s_out = %h, done = %d", s_in, r, s_out, done);
    end
    
    
endmodule
