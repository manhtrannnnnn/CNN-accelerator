`timescale 1ns/1ps
`include "defines.v"

module relu_activation #(
    parameter dataWidth = 16
)(
    input [dataWidth-1:0] data_in,
    output [dataWidth-1:0] data_out
);
    assign data_out = (data_in[dataWidth-1]) ? 0 : data_in;
endmodule