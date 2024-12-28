`timescale 1ns / 1ps

module input_mux #(
    parameter DATA_WIDTH = 8
)(
    input [DATA_WIDTH-1:0] in1,
    input [DATA_WIDTH-1:0] in2,
    input [1:0] sel,
    output [DATA_WIDTH-1:0] op
    );
    assign op = (sel == 2'b01) ? in1 : ((sel == 2'b00) ? in2: 0);
endmodule