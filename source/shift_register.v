`timescale 1ns/1ps

module shift_register #(
    parameter DATA_WIDTH = 16,
    parameter size = 3
)(
    input clk, ce, rst,
    input [DATA_WIDTH-1:0] data_in,
    output [DATA_WIDTH-1:0] data_out
);
    reg [DATA_WIDTH-1:0] tmp[size-1:0];
    
    generate
        genvar l;
        for (l = 0; l < size; l = l + 1) begin
            always @(posedge clk) begin
                if (rst) begin
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
