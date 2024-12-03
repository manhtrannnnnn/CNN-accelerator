`timescale 1ns / 1ps
`include "defines.v"

module convolver_tb;

    // Inputs
    reg clk;
    reg ce;
    reg [143:0] weight;
    reg global_rst;
    reg [15:0] myInput;
    reg [15:0] bias; 

    // Outputs
    wire [15:0] conv_op;
    wire valid_conv;
    wire end_conv;
    integer i;
    parameter clkp = 40; // Move parameter to the top level

    // Instantiate the Unit Under Test (UUT)
    convolver uut (
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

    initial begin
        // Initialize Inputs
        clk = 0;
        ce = 0;
        weight = 0;
        global_rst = 0;
        myInput = 0;
        bias = 16'd0;
        
        // Wait 100 ns for global reset to finish
        #clkp;
        global_rst = 1;    // Deactivate reset
        #(clkp/2);
        ce = 1;

        // Set weights (matching the golden model from Python code)
        weight = 144'h0008_0007_0006_0005_0004_0003_0002_0001_0000; 

        // Provide a range of activation values
        for (i = 0; i < 784; i = i + 1) begin
            myInput = i;
            #clkp;
            if (valid_conv == 1 && end_conv == 0) begin
                $display("conv_op at: %d", conv_op);
            end
 
        end
        $finish;
    end 

    // Clock generation
    always #(clkp/2) clk = ~clk;

    // Dump waveform for GTKWave
    initial begin
        $dumpfile("wave.vcd");
        $dumpvars(0, convolver_tb);
    end
endmodule