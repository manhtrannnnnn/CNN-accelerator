`timescale 1ns / 1ps
`include "defines.v"

module convolver_tb;

    // Inputs
    reg clk;
    reg ce;
    reg [(K*K)*dataWidth-1:0] weight;
    reg global_rst;
    reg [dataWidth-1:0] myInput;
    reg [dataWidth-1:0] bias;

    // Outputs
    wire [dataWidth-1:0] conv_op;
    wire valid_conv;
    wire end_conv;

    // Parameters
    parameter clkp = 40;                 // Clock period in ns
    parameter dataWidth = 8;           // Data width
    parameter W = 58;                   // Input width/height
    parameter K = 3;                    // Kernel size
    parameter s = 1;                    // Stride
    integer i;
    integer pass_count = 0;

    // Memory to hold input, kernel, and expected output
    reg [dataWidth-1:0] input_data [0:W*W-1];  // Input activations
    reg [dataWidth-1:0] kernel_data [0:K*K-1]; // Kernel weights
    reg [dataWidth-1:0] convo_output [0:(W-K+1)*(W-K+1)-1]; // Convolution outputs

    // Instantiate the Unit Under Test (UUT)
    convolver #(
        .dataWidth(dataWidth),
        .W(W),
        .K(K),
        .s(s)
    ) uut (
        .clk(clk),
        .ce(ce),
        .global_rst(global_rst),
        .myInput(myInput),
        .weight(weight),
        .bias(bias),
        .conv_op(conv_op),
        .valid_conv(valid_conv),
        .end_conv(end_conv)
    );

    // Testbench initialization
    initial begin
        // Initialize inputs
        clk = 0;
        ce = 0;
        weight = 0;
        global_rst = 1;
        myInput = 0;
        bias = 0;

        // Read input and kernel values from files
        $readmemb("../../python/input.txt", input_data);       // Input activations
        $readmemb("../../python/kernel.txt", kernel_data);     // Kernel weights
        $readmemb("../../python/convo_output.txt", convo_output); // Expected convolution outputs

        // Pack kernel data into weight
        weight = {kernel_data[8], kernel_data[7], kernel_data[6],
                  kernel_data[5], kernel_data[4], kernel_data[3],
                  kernel_data[2], kernel_data[1], kernel_data[0]};

        // Deactivate reset
        #clkp;
        global_rst = 0;
        #(clkp / 2);
        ce = 1;

        // Feed inputs and monitor outputs
        for (i = 0; i < W*W; i = i + 1) begin
            myInput = input_data[i];
            #clkp;
            if (valid_conv && !end_conv) begin
                if (pass_count < (W-K+1)*(W-K+1)) begin
                    if (conv_op == convo_output[pass_count]) begin
                        $display("Test Passed for output %d: %b", pass_count, conv_op);
                    end else begin
                        $display("Test Failed for output %d: expected %b, got %b", pass_count, convo_output[pass_count], conv_op);
                    end
                    pass_count = pass_count + 1; // Move to next expected output
                end
            end
        end
        $finish;
    end

    // Clock generation
    always #(clkp / 2) clk = ~clk;

    // Dump waveform for GTKWave
    initial begin
        $dumpfile("wave.vcd");
        $dumpvars(0, convolver_tb);
    end
endmodule
