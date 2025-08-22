`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 07/11/2025 06:53:10 PM
// Design Name: 
// Module Name: ascon_p_serial_multiround_tb
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

module ascon_p_serial_multiround_tb();  // core using ROM

    // Parameters
    parameter BW = 64;

    // -- Testbench Registers and Wires -- //
    reg clk;
    reg rstn;
    reg en;
    reg en_inc;
    reg [2:0] slice_idx;
    reg [BW-1:0] slice_in;

    wire [BW-1:0] slice_out;
    wire [3:0] r;
    wire done;

    // Internal array to store the final output state for verification
    reg [BW-1:0] final_state_out [0:4];

    // -- DUT INSTANTIATION -- //
    ascon_p_serial_multiround #(
        .BW(BW)
    ) uut (
        .clk(clk),
        .rstn(rstn),
        .en(en),
        .en_inc(en_inc),
        .slice_idx(slice_idx),
        .slice_in(slice_in),
        .slice_out(slice_out),
        .r(r),
        .done(done)
    );

    // -- CLOCK GENERATOR -- //
    always #2 clk = ~clk;

    // -- STIMULUS AND SIMULATION CONTROL -- //
    initial begin
        // 1. Initialize all signals
        $display("INFO: Initializing testbench signals...");
        clk = 1;
        rstn = 0; // Assert reset
        en = 0;
        en_inc = 0;
        slice_idx = 0;
        slice_in = 0;

        // 2. Apply and release reset
        #8; // Hold reset for 2 clock cycles
        rstn = 1;
        $display("INFO: Reset released at time %t.", $time);
        @(posedge clk);

        // 3. Main Test Sequence
        $display("INFO: Starting test sequence...");

        // A. Serially load the 5 input slices with random data
        $display("INFO: Loading initial state...");
        en = 1; // Enable loading
        for (integer j = 0; j < 5; j = j + 1) begin
            slice_idx = j;
            slice_in = {$urandom(), $urandom()}; // New random 64-bit slice
            @(posedge clk);
        end
        en = 0; // Disable loading

        // B. Start the internal 12-round permutation and wait for it to finish
        $display("INFO: Input loading complete. Starting 12-round permutation...");
        en_inc = 1;
        while (!done) begin
            @(posedge clk);
        end
        en_inc = 0;
        $display("INFO: Permutation for 12 rounds complete at time %t.", $time);
        
        // C. Serially read the final 5 output slices
        $display("INFO: Reading final output state...");
        for (integer k = 0; k < 5; k = k + 1) begin
            // Set the slice index to select which slice of the final state to read
            slice_idx = k;

            // Wait one clock cycle for the selection to propagate through the
            // output MUX and be captured by the DUT's slice_out register.
            @(posedge clk);

            // Now sample the stable output from the DUT
            final_state_out[k] = slice_out;
        end

        // D. Display the final results
        $display("--------------------------------------------------");
        $display("RESULT @ %t:", $time);
        $display("\tFinal State = %h_%h_%h_%h_%h", final_state_out[0], final_state_out[1], final_state_out[2], final_state_out[3], final_state_out[4]);
        
        // E. End the simulation
        $display("--------------------------------------------------");
        $display("SUCCESS: Test completed. Finishing simulation.");
        #10;
        $finish;
    end

    // Monitor key signals during the simulation
    initial begin
        $monitor("TIME=%t: en=%b, en_inc=%b, r=%d, done=%b, slice_idx=%d, slice_in=%h, slice_out=%h", 
                 $time, en, en_inc, r, done, slice_idx, slice_in, slice_out);
    end

endmodule
