`timescale 1ns / 1ps

module convolver_tb;

    // Parameters using defines
    parameter DATA_WIDTH = 8;
    parameter INPUT_SIZE = 28;
    parameter KERNEL_SIZE = 3;
    parameter STRIDE = 1;
    parameter CLK_PERIOD = 40;  // Clock period in ns

    // Inputs
    reg clk;
    reg ce;
    reg [(KERNEL_SIZE*KERNEL_SIZE)*DATA_WIDTH-1:0] weight;
    reg global_rst;
    reg [DATA_WIDTH-1:0] myInput;
    reg [DATA_WIDTH-1:0] bias;

    // Outputs
    wire [DATA_WIDTH-1:0] conv_op;
    wire valid_conv;
    wire end_conv;

    // Test variables
    integer i;
    integer pass_count = 0;

    // Memory to hold input, kernel, and expected output
    reg [DATA_WIDTH-1:0] input_data [0:INPUT_SIZE*INPUT_SIZE-1];  // Input activations
    reg [DATA_WIDTH-1:0] kernel_data [0:KERNEL_SIZE*KERNEL_SIZE-1]; // Kernel weights
    reg [DATA_WIDTH-1:0] convo_output [0:(INPUT_SIZE-KERNEL_SIZE+1)*(INPUT_SIZE-KERNEL_SIZE+1)-1]; // Convolution outputs

    // Instantiate the Unit Under Test (UUT)
    convolver #(
        .DATA_WIDTH(DATA_WIDTH),
        .INPUT_SIZE(INPUT_SIZE),
        .KERNEL_SIZE(KERNEL_SIZE),
        .STRIDE(STRIDE)
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
        weight = 0;
        for (i = 0; i < KERNEL_SIZE*KERNEL_SIZE; i = i + 1) begin
            weight = weight | (kernel_data[i] << (i * DATA_WIDTH));
        end

        // Deactivate reset
        #CLK_PERIOD;
        global_rst = 0;
        #(CLK_PERIOD / 2);
        ce = 1;

        // Feed inputs and monitor outputs
        for (i = 0; i < INPUT_SIZE*INPUT_SIZE; i = i + 1) begin
            myInput = input_data[i];
            #CLK_PERIOD;
            if (valid_conv && !end_conv) begin
                if (pass_count < (INPUT_SIZE-KERNEL_SIZE+1)*(INPUT_SIZE-KERNEL_SIZE+1)) begin
                    if (conv_op == convo_output[pass_count]) begin
                        $display("Test %0d PASSED: Output = %b", pass_count, conv_op);
                    end else begin
                        $display("Test %0d FAILED: Expected %b, Got %b", 
                                pass_count, convo_output[pass_count], conv_op);
                    end
                    pass_count = pass_count + 1;
                end
            end
        end

        // Display final test results
        #(CLK_PERIOD * 10);
        $display("\nTest Summary:");
        $display("Total tests: %0d", (INPUT_SIZE-KERNEL_SIZE+1)*(INPUT_SIZE-KERNEL_SIZE+1));
        $display("Tests completed: %0d", pass_count);
        $finish;
    end

    // Clock generation
    always #(CLK_PERIOD / 2) clk = ~clk;

    // Dump waveform for GTKWave
    initial begin
        $dumpfile("wave.vcd");
        $dumpvars(0, convolver_tb);
    end

endmodule
