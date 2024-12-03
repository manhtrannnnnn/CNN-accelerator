`timescale 1ns/1ps
`include "defines.v"

module shift_register #(
    parameter dataWidth = 16,
    parameter size = 3
)(
    input clk, ce, rst,
    input [dataWidth-1:0] data_in,
    output [dataWidth-1:0] data_out
);
    reg [dataWidth-1:0] tmp[size-1:0];
    
    generate
        genvar l;
        for (l = 0; l < size; l = l + 1) begin
            always @(posedge clk or negedge rst) begin
                if (!rst) begin
                    tmp[l] <= 'd0;
                end
                else if (ce) begin
                    if (l == 'd0) begin
                        tmp[l] <= data_in;  
                    end
                    else begin
                        tmp[l] <= tmp[l-1];
                    end
                end
            end
        end
    assign data_out = tmp[size-1];
    endgenerate
    
endmodule
