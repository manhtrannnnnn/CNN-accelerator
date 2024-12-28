`timescale 1ns / 1ps

module comparator2 #(
    parameter DATA_WIDTH = 16,
    parameter POOL_TYPE = 1
    )(
    input ce,
    input [DATA_WIDTH-1:0] in1,
    input [DATA_WIDTH-1:0] in2,
    output [DATA_WIDTH-1:0] comp_op
    ); 
    reg [DATA_WIDTH-1:0] temp;
    assign comp_op = ce ? temp : 'd0;

    always@(*)
    begin
        if(POOL_TYPE == 0)
        begin
            temp = in1 + in2;        
        end
        else begin
            temp = (in1 > in2) ? in1 : in2;
        end
    end
endmodule