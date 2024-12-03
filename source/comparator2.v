`timescale 1ns / 1ps

module comparator2 #(
    parameter dataWidth = 16,
    parameter ptype = 1
    )(
    input ce,
    input [dataWidth-1:0] in1,
    input [dataWidth-1:0] in2,
    output [dataWidth-1:0] comp_op
    ); 
    reg [dataWidth-1:0] temp;
    assign comp_op = ce ? temp : 'd0;

    always@(*)
    begin
        if(ptype == 0)
        begin
            temp = in1 + in2;        
        end
        else begin
            temp = (in1 > in2) ? in1 : in2;
        end
    end
endmodule