`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company:
// Engineer:
//
// Create Date: 06/14/2025 08:30:15 AM
// Design Name:
// Module Name: ascon_p_core_tb
// Project Name:
// Target Devices:
// Tool Versions:
// Description: Testbench for the ascon_p_core module.
//              This testbench cycles through 12 rounds (0 to 11), providing
//              a new random s_in value for each round.
//
// Dependencies: ascon_p_core.v
//
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
//
//////////////////////////////////////////////////////////////////////////////////

module ascon_p_core_tb();

    // Parameters
    parameter BW = 64;

    // -- REGISTERS AND WIRES -- //
    // Testbench registers to drive the DUT inputs
    reg clk;
    reg rstn;
    reg [3:0] round;
    reg [BW*5 - 1:0] s_in;

    // Wire to capture the DUT output
    wire [BW*5 - 1:0] s_out;


    // -- DUT INSTANTIATION -- //
    // Instantiate the Device Under Test (ascon_p_core)
    ascon_p_core_rom #(
        .BW(BW)
    ) uut (
        .clk(clk),
        .rstn(rstn),
        .round(round),
        .s_in(s_in),
        .s_out(s_out)
    );


    // -- CLOCK GENERATOR -- //
    // Generate a clock signal with a period of 4ns (250 MHz)
    always #2 clk = ~clk;


    // -- STIMULUS AND SIMULATION CONTROL -- //
    initial begin
        // 1. Initialize all signals at the beginning of the simulation
        $display("INFO: Initializing testbench signals...");
        clk = 1;
        rstn = 0; // Assert reset
        round = 0;
        s_in = 0;

        // 2. Apply and release reset
        // Hold reset active for 8ns (2 clock cycles) to ensure DUT is properly reset
        #8;
        rstn = 1; // De-assert reset
        $display("INFO: Reset released at time %t.", $time);

        // Wait for the first positive clock edge after reset is released
        @(posedge clk);

        // 3. Main test loop: Iterate through rounds 0 to 11
        $display("INFO: Starting 12 rounds of testing with random inputs...");
        for (integer i = 0; i < 12; i = i + 1) begin
            // Assign the current round number
            round = i;

            // Generate a new 320-bit random value for s_in
            // We concatenate 10 calls to $urandom() since each returns a 32-bit value
            s_in = {$urandom(), $urandom(), $urandom(), $urandom(), $urandom(), $urandom(), $urandom(), $urandom(), $urandom(), $urandom()};

            // Wait for one full clock cycle for the DUT's combinational logic to process the new inputs
            @(posedge clk);

            // Display the results for the current round
            $display("ROUND %0d @ %t: s_in = %h, s_out = %h", round, $time, s_in, s_out);
        end

        // 4. End the simulation
        $display("SUCCESS: All 12 rounds completed. Finishing simulation.");
        #10; // Wait a bit before finishing to ensure the last message is seen
        $finish;
    end
    
    // -- CONSOLE MONITOR -- //
    // This block continuously monitors and prints the signal values whenever they change.
    // Useful for detailed debugging.
    initial begin
        $monitor("MONITOR @ %t: rstn=%b, round=%d, s_in=%h, s_out=%h", $time, rstn, round, s_in, s_out);
    end

endmodule
