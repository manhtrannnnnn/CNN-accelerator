`timescale 1ns / 1ps

module layer_tb;

    // Parameters
    parameter dataWidth = 16;
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

    // Monitor output
    always @(posedge clk) begin
        if (valid_op == 1 && end_op == 0) begin
            $display("Time: %0t, Data_out: %b", $time, data_out);
        end
    end

endmodule
