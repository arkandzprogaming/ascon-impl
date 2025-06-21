//`timescale 1ns / 1ps
////////////////////////////////////////////////////////////////////////////////////
//// Company:
//// Engineer:
////
//// Create Date: 06/18/2025 01:45:10 AM
//// Design Name:
//// Module Name: ascon_p_serial_tb
//// Project Name:
//// Target Devices:
//// Tool Versions:
//// Description: Testbench for the ascon_p_serial module.
////              This testbench cycles through 12 rounds (0 to 11). For each
////              round, it serially loads a full 320-bit state with random data,
////              then serially reads the resulting 320-bit output state.
////
//// Dependencies: ascon_p_serial.v
////
//// Revision:
//// Revision 0.01 - File Created
//// Additional Comments:
////
////////////////////////////////////////////////////////////////////////////////////

//module ascon_p_serial_tb();

//    // Parameters
//    parameter BW = 64;

//    // -- Testbench Registers and Wires -- //
//    // Registers to drive the DUT inputs
//    reg clk;
//    reg rstn;
//    reg en;
//    reg [2:0] slice_idx;
//    reg [3:0] round;
//    reg [BW-1:0] slice_in;

//    // Wire to capture the DUT output
//    wire [BW-1:0] slice_out;

//    // Internal arrays to store the full state for logging
//    reg [BW-1:0] temp_s_in [0:4];
//    reg [BW-1:0] temp_s_out [0:4];

//    // -- DUT INSTANTIATION -- //
//    ascon_p_serial #(
//        .BW(BW)
//    ) uut (
//        .clk(clk),
//        .rstn(rstn),
//        .en(en),
//        .slice_idx(slice_idx),
//        .round(round),
//        .slice_in(slice_in),
//        .slice_out(slice_out)
//    );

//    // -- CLOCK GENERATOR -- //
//    // Generate a clock signal with a period of 4ns (250 MHz)
//    always #2 clk = ~clk;

//    // -- STIMULUS AND SIMULATION CONTROL -- //
//    initial begin
//        // 1. Initialize all signals
//        $display("INFO: Initializing testbench signals...");
//        clk = 1;
//        rstn = 0; // Assert reset
//        en = 0;
//        slice_idx = 0;
//        round = 0;
//        slice_in = 0;

//        // 2. Apply and release reset
//        #8; // Hold reset for 2 clock cycles
//        rstn = 1;
//        $display("INFO: Reset released at time %t.", $time);
//        @(posedge clk);

//        // 3. Main test loop: Iterate through rounds 0 to 11
//        $display("INFO: Starting 12 rounds of serial testing...");
//        for (integer i = 0; i < 12; i = i + 1) begin
//            round = i;
//            $display("--------------------------------------------------");
//            $display("INFO: Starting ROUND %0d", round);

//            // A. Serially load the 5 input slices with random data
//            en = 1; // Enable loading
//            for (integer j = 0; j < 5; j = j + 1) begin
//                slice_idx = j;
//                slice_in = {$urandom(), $urandom()}; // New random 64-bit slice
//                temp_s_in[j] = slice_in; // Store for logging
//                @(posedge clk);
//            end
//            en = 0; // Disable loading after all 5 slices are in

//            // Give one clock cycle for the last loaded state to propagate if needed
//            @(posedge clk);

//            // B. Serially read the 5 output slices
//            $display("INFO: [Round %0d] Input loading complete. Reading output slices...", round);
//            for (integer k = 0; k < 5; k = k + 1) begin
//                slice_idx = k;
//                // The output is combinational, but we wait a small delay for the
//                // MUX to settle before sampling, then wait for the next clock.
////                #1;
//                temp_s_out[k] = slice_out;
//                @(posedge clk);
//            end

//            // C. Display the full input and output states for the completed round
//            $display("RESULT [Round %0d] @ %t:", round, $time);
//            $display("\tFull s_in  = %h_%h_%h_%h_%h", temp_s_in[0], temp_s_in[1], temp_s_in[2], temp_s_in[3], temp_s_in[4]);
//            $display("\tFull s_out = %h_%h_%h_%h_%h", temp_s_out[0], temp_s_out[1], temp_s_out[2], temp_s_out[3], temp_s_out[4]);
//        end

//        // 4. End the simulation
//        $display("--------------------------------------------------");
//        $display("SUCCESS: All 12 rounds completed. Finishing simulation.");
//        #10;
//        $finish;
//    end

//endmodule


//`timescale 1ns / 1ps
////////////////////////////////////////////////////////////////////////////////////
//// Company:
//// Engineer:
////
//// Create Date: 06/18/2025 01:45:10 AM
//// Design Name:
//// Module Name: ascon_p_serial_tb
//// Project Name:
//// Target Devices:
//// Tool Versions:
//// Description: Testbench for the ascon_p_serial module.
////              This testbench cycles through 12 rounds (0 to 11). For each
////              round, it serially loads a full 320-bit state with random data,
////              then serially reads the resulting 320-bit output state.
////
//// Dependencies: ascon_p_serial.v
////
//// Revision:
//// Revision 0.01 - File Created
//// Revision 0.02 - Modified to support the registered output version of the DUT,
////                 accounting for the 1-cycle output latency.
//// Additional Comments:
////
////////////////////////////////////////////////////////////////////////////////////

//module ascon_p_serial_tb();

//    // Parameters
//    parameter BW = 64;

//    // -- Testbench Registers and Wires -- //
//    // Registers to drive the DUT inputs
//    reg clk;
//    reg rstn;
//    reg en;
//    reg [2:0] slice_idx;
//    reg [3:0] round;
//    reg [BW-1:0] slice_in;

//    // Wire to capture the DUT output
//    wire [BW-1:0] slice_out;

//    // Internal arrays to store the full state for logging
//    reg [BW-1:0] temp_s_in [0:4];
//    reg [BW-1:0] temp_s_out [0:4];

//    // -- DUT INSTANTIATION -- //
//    ascon_p_serial #(
//        .BW(BW)
//    ) uut (
//        .clk(clk),
//        .rstn(rstn),
//        .en(en),
//        .slice_idx(slice_idx),
//        .round(round),
//        .slice_in(slice_in),
//        .slice_out(slice_out)
//    );

//    // -- CLOCK GENERATOR -- //
//    // Generate a clock signal with a period of 4ns (250 MHz)
//    always #2 clk = ~clk;

//    // -- STIMULUS AND SIMULATION CONTROL -- //
//    initial begin
//        // 1. Initialize all signals
//        $display("INFO: Initializing testbench signals...");
//        clk = 1;
//        rstn = 0; // Assert reset
//        en = 0;
//        slice_idx = 0;
//        round = 0;
//        slice_in = 0;

//        // 2. Apply and release reset
//        #8; // Hold reset for 2 clock cycles
//        rstn = 1;
//        $display("INFO: Reset released at time %t.", $time);
//        @(posedge clk);

//        // 3. Main test loop: Iterate through rounds 0 to 11
//        $display("INFO: Starting 12 rounds of serial testing...");
//        for (integer i = 0; i < 12; i = i + 1) begin
//            round = i;
//            $display("--------------------------------------------------");
//            $display("INFO: Starting ROUND %0d", round);

//            // A. Serially load the 5 input slices with random data
//            en = 1; // Enable loading
//            for (integer j = 0; j < 5; j = j + 1) begin
//                slice_idx = j;
//                slice_in = {$urandom(), $urandom()}; // New random 64-bit slice
//                temp_s_in[j] = slice_in; // Store for logging
//                @(posedge clk);
//            end
//            en = 0; // Disable loading after all 5 slices are in
//            // B. Serially read the 5 output slices
//            // This loop is modified for the registered output DUT.
//            $display("INFO: [Round %0d] Input loading complete. Reading output slices...", round);
//            for (integer k = 0; k < 5; k = k + 1) begin
//                // Set the index to select which slice's result is routed to the output register
//                slice_idx = k;

//                // Wait for the next clock edge. This is the moment the selected 'tmp' value
//                // (based on the slice_idx we just set) gets captured by the 'slice_out' register.
//                @(posedge clk);

//                // Now that the clock has ticked, the 'slice_out' register holds the stable
//                // result for slice 'k'. We can sample it.
//                temp_s_out[k] = slice_out;
//            end
            
////            @(posedge clk);
            
//            // C. Display the full input and output states for the completed round
//            $display("RESULT [Round %0d] @ %t:", round, $time);
//            $display("\tFull s_in  = %h_%h_%h_%h_%h", temp_s_in[0], temp_s_in[1], temp_s_in[2], temp_s_in[3], temp_s_in[4]);
//            $display("\tFull s_out = %h_%h_%h_%h_%h", temp_s_out[0], temp_s_out[1], temp_s_out[2], temp_s_out[3], temp_s_out[4]);
//        end

//        // 4. End the simulation
//        $display("--------------------------------------------------");
//        $display("SUCCESS: All 12 rounds completed. Finishing simulation.");
//        #10;
//        $finish;
//    end

//endmodule


`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company:
// Engineer:
//
// Create Date: 06/18/2025 01:45:10 AM
// Design Name:
// Module Name: ascon_p_serial_tb
// Project Name:
// Target Devices:
// Tool Versions:
// Description: Testbench for the ascon_p_serial module.
//              This testbench cycles through 12 rounds (0 to 11). For each
//              round, it serially loads a full 320-bit state with random data,
//              then serially reads the resulting 320-bit output state.
//
// Dependencies: ascon_p_serial.v
//
// Revision:
// Revision 0.01 - File Created
// Revision 0.02 - Modified to support the registered output version of the DUT.
// Revision 0.03 - Corrected the output reading loop to fix the one-cycle mismatch
//                 and ensure output slices are read in the correct order.
// Additional Comments:
//
//////////////////////////////////////////////////////////////////////////////////

module ascon_p_serial_tb();

    // Parameters
    parameter BW = 64;

    // -- Testbench Registers and Wires -- //
    // Registers to drive the DUT inputs
    reg clk;
    reg rstn;
    reg en;
    reg [2:0] slice_idx;
    reg [3:0] round;
    reg [BW-1:0] slice_in;

    // Wire to capture the DUT output
    wire [BW-1:0] slice_out;

    // Internal arrays to store the full state for logging
    reg [BW-1:0] temp_s_in [0:4];
    reg [BW-1:0] temp_s_out [0:4];

    // -- DUT INSTANTIATION -- //
    ascon_p_serial #(
        .BW(BW)
    ) uut (
        .clk(clk),
        .rstn(rstn),
        .en(en),
        .slice_idx(slice_idx),
        .round(round),
        .slice_in(slice_in),
        .slice_out(slice_out)
    );

    // -- CLOCK GENERATOR -- //
    // Generate a clock signal with a period of 4ns (250 MHz)
    always #2 clk = ~clk;

    // -- STIMULUS AND SIMULATION CONTROL -- //
    initial begin
        // 1. Initialize all signals
        $display("INFO: Initializing testbench signals...");
        clk = 1;
        rstn = 0; // Assert reset
        en = 0;
        slice_idx = 0;
        round = 0;
        slice_in = 0;

        // 2. Apply and release reset
        #8; // Hold reset for 2 clock cycles
        rstn = 1;
        $display("INFO: Reset released at time %t.", $time);
        @(posedge clk);

        // 3. Main test loop: Iterate through rounds 0 to 11
        $display("INFO: Starting 12 rounds of serial testing...");
        for (integer i = 0; i < 12; i = i + 1) begin
            round = i;
            $display("--------------------------------------------------");
            $display("INFO: Starting ROUND %0d", round);

            // A. Serially load the 5 input slices with random data
            en = 1; // Enable loading
            for (integer j = 0; j < 5; j = j + 1) begin
                slice_idx = j;
                slice_in = {$urandom(), $urandom()}; // New random 64-bit slice
                temp_s_in[j] = slice_in; // Store for logging
                @(posedge clk);
            end
            en = 0; // Disable loading after all 5 slices are in

            // B. Serially read the 5 output slices
            // This loop is corrected to handle the 1-cycle output latency correctly.
            $display("INFO: [Round %0d] Input loading complete. Reading output slices...", round);

            // Prime the pipeline: Set slice_idx to 0 so its result is ready after the next clock.
            slice_idx = 0;
            @(posedge clk);

            // Now, read the results in a pipelined fashion.
            for (integer k = 0; k < 6; k = k + 1) begin
                // 1. Read the result that was latched on the previous clock edge.
                //    For k=0, this is the result for slice_idx=0 that we just primed.
                if (k >= 1) 
                    temp_s_out[k - 1] = slice_out;

                // 2. Set the index for the *next* iteration.
                //    This ensures the correct data is selected by the MUX before the next clock.
                if (k < 4) begin
                    slice_idx = k + 1;
                end

                // 3. Wait for the clock tick.
                @(posedge clk);
            end

            // C. Display the full input and output states for the completed round
            $display("RESULT [Round %0d] @ %t:", round, $time);
            $display("\tFull s_in  = %h_%h_%h_%h_%h", temp_s_in[0], temp_s_in[1], temp_s_in[2], temp_s_in[3], temp_s_in[4]);
            $display("\tFull s_out = %h_%h_%h_%h_%h", temp_s_out[0], temp_s_out[1], temp_s_out[2], temp_s_out[3], temp_s_out[4]);
        end

        // 4. End the simulation
        $display("--------------------------------------------------");
        $display("SUCCESS: All 12 rounds completed. Finishing simulation.");
        #10;
        $finish;
    end

endmodule

