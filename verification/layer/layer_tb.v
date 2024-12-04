`timescale 1ns / 1ps

module layer_tb;

    // Parameters
    parameter dataWidth = 8;
    parameter W = 9'h01C;
    parameter K = 9'h003;
    parameter P = 9'h002;
    parameter s = 1;
    parameter actype = 1'b1;  // 0 => tanh, 1 => relu

    // Inputs
    reg clk;
    reg global_rst;
    reg ce;
    reg [dataWidth-1:0] myInput;
    reg [K*K*dataWidth-1:0] weight;
    reg [dataWidth-1:0] bias;

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

    integer i, j;
    reg [dataWidth-1:0] input_data [0:W*W-1];  // 6x6 input
    reg [dataWidth-1:0] kernel_data [0:K*K-1]; // 3x3 kernel
    reg [dataWidth-1:0] pooling_out_data [0:((W-K+1)/2)*((W-K+1)/2)-1]; // Pooling output data

    // Test sequence
    initial begin
        // Initialize inputs
        ce = 0;
        weight = 0;
        global_rst = 0;
        myInput = 0;
        bias = 0;

        // Read input file
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
        global_rst = 1;    // Activate reset   
        ce = 1;

        // Provide input values sequentially
        for (i = 0; i < W*W; i = i + 1) begin
            myInput = input_data[i];
            #(clkp); 
        end
        #100;
        $finish;
    end 

    // Dump waveform for GTKWave
    initial begin
        $dumpfile("wave.vcd");
        $dumpvars(0, layer_tb);
    end

    // Monitor output and compare with pooling_out
    integer pass_count = 0;
    always @(posedge clk) begin
        if (valid_op == 1 && end_op == 0) begin
            // Compare data_out with pooling_out_data
            if (pass_count < ((W-K+1)/2)*((W-K+1)/2)) begin
                if (data_out == pooling_out_data[pass_count]) begin
                    $display("Test Passed for output %d: %b", pass_count, data_out);
                end else begin
                    $display("Test Failed for output %d: expected %b, got %b", pass_count, pooling_out_data[pass_count], data_out);
                end
                pass_count = pass_count + 1; // Move to next expected output
            end
        end
    end

endmodule