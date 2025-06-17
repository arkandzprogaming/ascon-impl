//`timescale 1ns / 1ps
////////////////////////////////////////////////////////////////////////////////////
//// Company: 
//// Engineer: 
//// 
//// Create Date: 03/17/2025 08:59:02 AM
//// Design Name: 
//// Module Name: ascp_tb
//// Project Name: 
//// Target Devices: 
//// Tool Versions: 
//// Description: 
//// 
//// Dependencies: 
//// 
//// Revision:
//// Revision 0.01 - File Created
//// Additional Comments:
//// 
////////////////////////////////////////////////////////////////////////////////////


//module ascp_tb();
//    parameter BW = 64;
    
//    // input
//    reg clk;
//    reg rstn;
//    reg [BW*5 - 1:0] s_in;
    
//    // output
//    wire [BW*5 - 1:0] s_out;
//    wire [3:0] r;   // For monitoring purposes
//    wire done;
    
//    ascon_p #(BW) uut(
//        .clk(clk),
//        .rstn(rstn),
//        .s_in(s_in),
//        .s_out(s_out),
//        .r(r),
//        .done(done)
//    );
    
//    // signal generator
//    always #2 clk = ~clk;
    
//    initial begin
//        // Initialize signals
//        clk = 1;
//        rstn = 0;   // Counter loads initial value (load == !rstn)
        
//        // State initial value
//        s_in = {64'h00400C0000000100, 256'h0};
        
//        // Reset sequence
//        #4 rstn = 1;
        
//        // End simulation
//        forever begin
//            @(posedge clk);
//            if (done) begin
//                $display("Completed 12 rounds at time %t", $time);
//                $finish; // Delay last iteration for a whole cycle before finishing
//            end
//        end
//    end
    
//    // Monitor in console
//    initial begin
//        $monitor($time, " s_in = %h, r = %d, s_out = %h, done = %d", s_in, r, s_out, done);
//    end
    
    
//endmodule


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
// This testbench has been modified to provide 10 consecutive random inputs
// to the ascon_p module, waiting for each operation to complete before
// sending the next one.
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Revision 0.02 - Modified to provide 10 random inputs continuously.
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module ascp_tb();
    parameter BW = 64;
    
    // input
    reg clk;
    reg rstn;
    reg load;
    reg [BW*5 - 1:0] s_in;
    
    // output
    wire [BW*5 - 1:0] s_out;
    wire [3:0] r;   // For monitoring purposes
    wire done;
    
    // Instantiate the Device Under Test (DUT)
    ascon_p #(BW) uut(
        .clk(clk),
        .rstn(rstn),
        .load(load),
        .s_in(s_in),
        .s_out(s_out),
        .r(r),
        .done(done)
    );
    
    // Clock generator: creates a clock with a 4ns period.
    always #2 clk = ~clk;
    
    // This block generates stimulus and controls the simulation.
    initial begin
        // Initialize signals at the beginning of the simulation
        clk = 1;
        rstn = 0;   // Assert reset to put the DUT in a known state
        load = 0;
        s_in = 0;   // Initialize input to a known value
        
        // Apply reset for 2 clock cycles (4ns)
        #4;
      rstn = 1;   // De-assert reset to allow the DUT to start operating
      load = 1;
        
      // Wait for the next positive clock edge to ensure reset is processed
      @(posedge clk);
      
      $display("INFO: Starting 10 rounds of random inputs...");

        // Loop 10 times to provide continuous random inputs
        for (integer i = 0; i < 10; i = i + 1) begin
            // Generate a 320-bit random value for s_in using SystemVerilog's $urandom
            // Each $urandom() call generates a 32-bit value. 10 are concatenated.
            s_in = {$urandom(), $urandom(), $urandom(), $urandom(), $urandom(), $urandom(), $urandom(), $urandom(), $urandom(), $urandom()};
            
            $display("INFO: [Cycle %0d] Applied new random input at time %t.", i + 1, $time);
            
            // Wait for the 'done' signal to be asserted by the DUT.
            // This loop waits synchronously until the current operation is complete.
            while (!done) begin
                load = 0;
                @(posedge clk);
            end
            
            if (done) load = 1;
            
            $display("INFO: [Cycle %0d] 'done' signal received at time %t. Operation complete.", i + 1, $time);
            
            // Wait one more clock cycle before starting the next iteration.
            @(posedge clk);
        end
        
        // End simulation after all 10 inputs have been processed
        $display("SUCCESS: Completed all 10 random input cycles at time %t. Finishing simulation.", $time);
        #10; // Wait a moment before finishing to allow final values to be monitored
        $finish;
    end
    
    // This block monitors key signals and prints their values to the console whenever they change.
    initial begin
        $monitor("MONITOR @ %t: s_in = %h, r = %d, s_out = %h, done = %b", $time, s_in, r, s_out, done);
    end
    
endmodule
