`timescale 1ns / 1ps

module input_mux #(
    parameter dataWidth = 8
)(
    input [dataWidth-1:0] in1,
    input [dataWidth-1:0] in2,
    input [1:0] sel,
    output [dataWidth-1:0] op
    );
    assign op = (sel == 2'b01) ? in1 : ((sel == 2'b00) ? in2: 0);
endmodule