`timescale  1ns/1ps
`include "defines.v"

module mac_manual #(
    parameter dataWidth = 16,
    parameter macType = "normalMac"
)(
    input clk, ce, rst,
    input [dataWidth-1:0] a, b, 
    input [dataWidth-1:0] tmp,
    output reg [dataWidth-1:0] data_out
); 
    always @(posedge clk) begin
        if(rst) begin
            data_out <= 0;
        end
        else begin
            data_out <= (a * b) + tmp;
        end
    end

endmodule