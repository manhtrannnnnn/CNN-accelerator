`timescale 1ns/1ps
`include "defines.v"

module convolver #(
    parameter dataWidth = 16,
    parameter W = 28,
    parameter K = 3,
    parameter s = 1
) (
    input clk, ce, global_rst, 
    input [dataWidth-1:0] myInput,
    input [(K*K)*dataWidth-1:0] weight,
    input [dataWidth-1:0] bias,
    output [dataWidth-1:0] conv_op,
    output reg valid_conv, end_conv
);

    // Temporary storage for separated weights and intermediate results
    wire [dataWidth-1:0] weight_tmp [K*K-1:0];
    wire [dataWidth-1:0] tmp [K*K+1:0];

    

    // Extract weights from the input vector
    generate 
        genvar j;
        for (j = 0; j < K*K; j = j + 1) begin
            assign weight_tmp[j][dataWidth-1:0] = weight[j*dataWidth +: dataWidth];
        end
    endgenerate

    assign tmp[0] = {dataWidth{1'b0}};
    // Implement MAC (Multiply-Accumulate) for convolution
    generate 
        genvar i;
        for (i = 0; i < K*K; i = i + 1) begin: MAC
            if ((i + 1) % K == 0) begin
                // Special case: Shift register for the last column of each row
                if (i == K*K-1) begin
                    mac_manual #(.dataWidth(dataWidth)) mac (
                        .clk(clk),
                        .ce(ce),
                        .rst(global_rst),
                        .a(myInput),
                        .b(weight_tmp[i]),
                        .tmp(tmp[i]),
                        .data_out(tmp[i+1])
                    );
                assign conv_op = tmp[i+1] + bias;
                end else begin
                    wire [dataWidth-1:0] tmp2;
                    mac_manual #(.dataWidth(dataWidth)) mac (
                        .clk(clk),
                        .ce(ce),
                        .rst(global_rst),
                        .a(myInput),
                        .b(weight_tmp[i]),
                        .tmp(tmp[i]),
                        .data_out(tmp2)
                    );
                    shift_register #(.dataWidth(dataWidth), .size(W-K)) sr (
                        .clk(clk),
                        .ce(ce),
                        .rst(global_rst),
                        .data_in(tmp2),
                        .data_out(tmp[i+1])
                    );
                end
            end else begin
                mac_manual #(.dataWidth(dataWidth)) mac (
                    .clk(clk),
                    .ce(ce),
                    .rst(global_rst),
                    .a(myInput),
                    .b(weight_tmp[i]),
                    .tmp(tmp[i]),
                    .data_out(tmp[i+1])
                );
            end
        end
    endgenerate
    

    // Row, column, and cycle counters to track convolution progress
    reg [$clog2(W):0] row_counter = 0;
    reg [$clog2(W):0] col_counter = 0;
    reg [$clog2(W*W):0] cycle_counter = 0;

    // Logic to control row and column counters
    always @(posedge clk) begin
        if (global_rst) begin
            row_counter <= 0;
            col_counter <= 0;
            cycle_counter <= 0;
        end else if (ce) begin
            if (col_counter + s >= W) begin
                col_counter <= 0;
                if (row_counter + s >= W) begin
                    row_counter <= 0;
                end else begin
                    row_counter <= row_counter + s;
                end
            end else begin
                col_counter <= col_counter + s;
            end
            cycle_counter <= cycle_counter + 1;
        end
    end

    // Generate `valid_conv` when at a valid convolution window
    always @(posedge clk) begin
        if (global_rst) begin
            valid_conv <= 0;
        end else if (ce) begin
            if ((row_counter >= K-1 && row_counter < W && (row_counter - (K-1)) % s == 0) &&
                (col_counter >= K-1 && col_counter < W && (col_counter - (K-1)) % s == 0)) begin
                valid_conv <= 1;
            end else begin
                valid_conv <= 0;
            end
        end
    end

    // Generate `end_conv` when the entire convolution is complete
    always @(posedge clk) begin
        if (global_rst) begin
            end_conv <= 0;
        end else if (ce && cycle_counter >= W*W) begin
            end_conv <= 1;
        end else begin
            end_conv <= 0;
        end
    end

endmodule
