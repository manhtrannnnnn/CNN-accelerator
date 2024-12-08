`timescale 1ns / 1ps
`include "defines.v"

module layer_tb;

    // Parameters
    parameter dataWidth = 8;
    parameter W = 124;
    parameter K = 3;
    parameter P = 2;
    parameter s = 1;
    parameter actype = 1'b1;  // 0 => tanh, 1 => relu

    // Inputs
    reg clk;
    reg global_rst;
    reg ce;
    reg [dataWidth-1:0] myInput;
    reg [K*K*dataWidth-1:0] weight;
    reg [dataWidth-1:0] bias;
    reg [dataWidth-1:0] act_op;
    reg valid_pooling;

    // Outputs
    wire [dataWidth-1:0] data_out;
    wire valid_op;
    wire end_op;

    // Instantiate the Unit Under Test (UUT)
    layer #(
        .dataWidth(dataWidth),
        .W(W),
        .K(K),
        .P(P),
        .s(s),
        .actype(actype)
    ) uut (
        .clk(clk),
        .global_rst(global_rst),
        .ce(ce),
        .myInput(myInput),
        .weight(weight),
        .bias(bias),
        .data_out(data_out),
        .valid_op(valid_op),
        .end_op(end_op)
    );

    // Clock period
    parameter clkp = 20;

    // Clock generation
    initial begin
        clk = 0;
        forever #(clkp/2) clk = ~clk;
    end

    integer i;
    reg [dataWidth-1:0] input_data [0:W*W-1];  // Input matrix
    reg [dataWidth-1:0] kernel_data [0:K*K-1]; // Kernel weights
    reg [dataWidth-1:0] pooling_out_data [0:((W-K+1)/2)*((W-K+1)/2)-1]; // Expected pooling outputs

    integer pass_count = 0;   // Count of passed tests
    integer fail_count = 0;   // Count of failed tests
    integer total_tests = 0;  // Total tests
    integer test_index = 0;   // Index for pooling_out_data

    // Test sequence
    initial begin
        // Initialize inputs
        ce = 0;
        weight = 0;
        global_rst = 1;
        myInput = 0;
        bias = 0;

        // Read input files
        $readmemb("../../python/input.txt", input_data);  // Load binary input values
        $readmemb("../../python/kernel.txt", kernel_data); // Load binary kernel values
        $readmemb("../../python/pooling_output.txt", pooling_out_data); // Load pooling output values

        // Map kernel data to weight
        weight = 0;
        for (i = 0; i < K*K; i = i + 1) begin
            weight = weight | (kernel_data[i] << (i * dataWidth));
        end

        // Wait for global reset to finish
        #100;
        global_rst = 0;    // Deactivate reset   
        ce = 1;

        // Provide input values sequentially
        for (i = 0; i < W*W; i = i + 1) begin
            myInput = input_data[i];
            #(clkp); 
        end
        #100;

        // Report results
        if (fail_count == 0) begin
            $display("\nSimulation Results: ALL TESTS PASSED (%d/%d passed)\n", pass_count, total_tests);
        end else begin
            $display("\nSimulation Results: TEST FAILED for %d outputs (%d/%d passed)\n", fail_count, pass_count, total_tests);
        end

        $finish;
    end 

    // Monitor output and compare with expected values
    always @(posedge clk) begin
        if (valid_op == 1 && end_op == 0) begin
            if (test_index < ((W-K+1)/2)*((W-K+1)/2)) begin
                total_tests = total_tests + 1;
                if (data_out == pooling_out_data[test_index]) begin
                    $display("Test Passed for output %d: got %b", test_index, data_out);
                    pass_count = pass_count + 1;
                end else begin
                    $display("Test Failed for output %d: expected %b, got %b", test_index, pooling_out_data[test_index], data_out);
                    fail_count = fail_count + 1;
                end
                // Increment the test index regardless of pass or fail
                test_index = test_index + 1;
            end
        end
    end

    // Dump waveform for GTKWave
    initial begin
        $dumpfile("wave.vcd");
        $dumpvars(0, layer_tb);
    end

endmodule