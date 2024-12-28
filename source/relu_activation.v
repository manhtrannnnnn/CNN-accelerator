`timescale 1ns/1ps

module relu_activation #(
    parameter DATA_WIDTH = 16
)(
    input [DATA_WIDTH-1:0] data_in,
    output [DATA_WIDTH-1:0] data_out
);
    assign data_out = (data_in[DATA_WIDTH-1] == 1) ? 0 : data_in;
endmodule