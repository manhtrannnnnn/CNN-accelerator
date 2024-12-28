`timescale  1ns/1ps

module mac_manual #(
    parameter DATA_WIDTH = 16
)(
    input clk, ce, rst,
    input [DATA_WIDTH-1:0] a, b, 
    input [DATA_WIDTH-1:0] tmp,
    output reg [DATA_WIDTH-1:0] data_out
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