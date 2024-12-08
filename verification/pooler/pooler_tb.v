`timescale 1ns/1ps
`include "defines.v"
module pooler_tb;

    // Parameters
    parameter M = 28;                  // Input matrix size (rows/columns)
    parameter P = 2;                  // Pooling window size
    parameter dataWidth = 8;              // Data width for inputs/outputs
    parameter ptype = 1;                   // Pooling type: 0 -> Average, 1 -> Max

    // Clock and reset signals
    reg clk;
    reg ce;
    reg master_rst;

    // Input and output signals
    reg [dataWidth-1:0] data_in;
    wire [dataWidth-1:0] data_out;
    wire valid_op;
    wire end_op;

    // Memory for input and expected output data
    reg [dataWidth-1:0] input_data [0:M*M-1];          // Assuming M x M matrix for input
    reg [dataWidth-1:0] pooling_out_data [0:(M/P)*(M/P)-1]; // Expected output data
    integer pass_count = 0;
    integer fail_count = 0;
    integer i;

    // Instantiate the pooler module
    pooler #(
        .M(M),
        .P(P),
        .dataWidth(dataWidth),
        .ptype(ptype)
    ) uut (
        .clk(clk),
        .ce(ce),
        .master_rst(master_rst),
        .data_in(data_in),
        .data_out(data_out),
        .valid_op(valid_op),
        .end_op(end_op)
    );

    // Clock generation
    initial clk = 0;
    always #5 clk = ~clk; // 10 ns clock period

    // Testbench initialization
    initial begin
        // Initialize signals
        ce = 0;
        master_rst = 1;
        data_in = 0;

        // Read input data from file
        $readmemb("../../python/relu_output.txt", input_data);
        // Read expected pooling output data from file
        $readmemb("../../python/pooling_output.txt", pooling_out_data);

        // Wait for reset deassertion
        #20;
        master_rst = 0;
        ce = 1;

        // Feed input data to the module
        for (i = 0; i < M * M; i = i + 1) begin
            data_in = input_data[i];
            #10; // Wait for one clock cycle
        end

        // Stop clock enable to finish the operation
        ce = 0;
        #200;

        // Report final test results
        $display("\nSimulation Results:");
        if (fail_count == 0) begin
            $display("All tests passed (%d/%d outputs)", pass_count, pass_count);
        end else begin
            $display("Test failed for %d outputs (%d/%d passed)", fail_count, pass_count, pass_count + fail_count);
        end

        // End simulation
        $finish;
    end

    // Monitor and compare outputs
    always @(posedge clk) begin
        if (valid_op == 1 && end_op == 0) begin
            // Compare data_out with pooling_out_data
            if (pass_count < (M/P) * (M/P)) begin
                if (data_out == pooling_out_data[pass_count]) begin
                    $display("Test Passed for output %d: %b", pass_count, data_out);
                    pass_count = pass_count + 1;
                end else begin
                    $display("Test Failed for output %d: expected %b, got %b", pass_count, pooling_out_data[pass_count], data_out);
                    fail_count = fail_count + 1;
                    pass_count = pass_count + 1;
                end
            end
        end
    end

    // Dump waveform for GTKWave
    initial begin
        $dumpfile("wave.vcd");
        $dumpvars(0, pooler_tb);
    end

endmodule
