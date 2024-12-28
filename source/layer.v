`timescale 1ns/1ps
`include "defines.vh"

module layer #(
    parameter DATA_WIDTH = `DATA_WIDTH,                 // Data width for inputs/outputs
    parameter INPUT_SIZE = `INPUT_SIZE,                 // Input matrix size
    parameter KERNEL_SIZE = `KERNEL_SIZE,               // Convolution kernel size
    parameter POOL_SIZE = `POOL_SIZE,                   // Pooling window size
    parameter STRIDE = `STRIDE,                         // Convolution stride
    parameter ACTIVATION_TYPE = `ACTIVATION_TYPE,       // 0 => tanh, 1 => relu
    parameter POOL_TYPE = `POOL_TYPE                    // 0 => average pooling, 1 => max pooling
)(
    input clk, global_rst, ce,
    input [DATA_WIDTH-1:0] myInput,
    input [KERNEL_SIZE*KERNEL_SIZE*DATA_WIDTH-1:0] weight,
    input [DATA_WIDTH-1:0] bias,
    output [DATA_WIDTH-1:0] data_out,
    output valid_op, 
    output end_op
);

    wire[DATA_WIDTH-1:0] conv_op;
    wire [DATA_WIDTH-1:0] act_op;
    wire valid_conv, end_conv;
    wire valid_pooling;
    
    assign valid_pooling = valid_conv && (!end_conv);

    convolver #(
        .DATA_WIDTH(DATA_WIDTH), 
        .INPUT_SIZE(INPUT_SIZE), 
        .KERNEL_SIZE(KERNEL_SIZE), 
        .STRIDE(STRIDE)
    ) conv(
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

    generate
        if(ACTIVATION_TYPE == 1'b0) begin
            tanh_activation #(.dataWidth(DATA_WIDTH), .addrWidth(256)) tanh_act(
                .data_in(conv_op),
                .data_out(act_op)
            );
        end
        else begin
            relu_activation #(.DATA_WIDTH(DATA_WIDTH)) relu_act(
                .data_in(conv_op),
                .data_out(act_op)
            );
        end
    endgenerate
    
    pooler #(
        .INPUT_SIZE(INPUT_SIZE-KERNEL_SIZE+1),
        .POOL_SIZE(POOL_SIZE), 
        .DATA_WIDTH(DATA_WIDTH), 
        .POOL_TYPE(POOL_TYPE)
    ) max_pooling(
        .clk(clk),
        .ce(valid_pooling),
        .master_rst(global_rst),
        .data_in(act_op),
        .data_out(data_out),
        .valid_op(valid_op),
        .end_op(end_op)
    );
endmodule
