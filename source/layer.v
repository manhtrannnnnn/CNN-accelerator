module layer #(
    parameter dataWidth = 8,
    parameter W = 9'h004,
    parameter K = 9'h003,
    parameter P = 9'h002,
    parameter s = 1,
    parameter actype = 1'b1, // 0 => tanh, 1 => relu
    parameter ptype = 1'b1  // 0 => average pooling, 1 => max pooling
)(
    input clk, global_rst, ce,
    input [dataWidth-1:0] myInput,
    input [K*K*dataWidth-1:0] weight,
    input [dataWidth-1:0] bias,
    output [dataWidth-1:0] data_out,
    output valid_op, 
    output end_op
);

    wire[dataWidth-1:0] conv_op;
    wire [dataWidth-1:0] act_op;
    wire valid_conv, end_conv;
    wire valid_pooling;
    

    assign valid_pooling = valid_conv && (!end_conv);

    convolver #(.dataWidth(dataWidth), .W(W), .K(K), .s(s)) conv(
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
        if(actype == 1'b0) begin
            tanh_activation #(.dataWidth(dataWidth), .addrWidth(256)) tanh_act(
                .data_in(conv_op),
                .data_out(act_op)
            );
        end
        else begin
            relu_activation #(.dataWidth(dataWidth)) relu_act(
                .data_in(conv_op),
                .data_out(act_op)
            );
        end
    endgenerate
    

    pooler #(.M(W-K+1),.P(P), .dataWidth(dataWidth), .ptype(ptype)) max_pooling(
        .clk(clk),
        .ce(valid_pooling),
        .master_rst(global_rst),
        .data_in(act_op),
        .data_out(data_out),
        .valid_op(valid_op),
        .end_op(end_op)
    );
endmodule