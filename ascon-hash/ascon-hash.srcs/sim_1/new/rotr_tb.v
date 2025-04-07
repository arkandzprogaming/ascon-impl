`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 02/23/2025 11:42:32 AM
// Design Name: 
// Module Name: rotr_tb
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


module rotr_tb();

    parameter BW = 64;
    
    // input
    reg clk;
    reg rstn;
    reg [BW - 1:0] val;    // input to be rotated
    reg [5:0] n;           // number of rotation up to 63
        
    // output
    wire [BW - 1:0] out;
    
    // uut
    rotr #(BW) uut(
        .clk(clk),
        .rstn(rstn),
        .val(val),
        .n(n),
        .out(out)
    );
    
    // signal generator
    always #2 clk = ~clk;
    
    initial begin
        // Initialize signals
        clk = 0;
        rstn = 0;
        val = 0;
        n = 0;
        
        // Reset sequence
        #10 rstn = 1;
        
        // Apply test cases
        #10 val = 64'h1234567890ABCDEF; n = 6'd4;  // Rotate right by 4 bits
        #10 val = 64'hFEDCBA9876543210; n = 6'd8;  // Rotate right by 8 bits
        #10 val = 64'hAAAAAAAAAAAAAAAA; n = 6'd16; // Rotate right by 16 bits
        #10 val = 64'h5555555555555555; n = 6'd32; // Rotate right by 32 bits
        #10 val = 64'hFFFFFFFFFFFFFFFF; n = 6'd63; // Rotate right by 63 bits
        
        // End simulation
        #20 $finish;
    end
    
    // Monitor outputs
    initial begin
        $monitor($time, " val = %h, n = %d, out = %h", val, n, out);
    end
    
    
endmodule
