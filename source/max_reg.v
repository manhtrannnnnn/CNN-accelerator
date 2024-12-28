`timescale 1ns / 1ps
module max_reg #(parameter DATA_WIDTH = 16) (
    input clk,
    input ce,
    input [DATA_WIDTH-1:0] data_in,
    input rst_m,
    input master_rst,
    output reg [DATA_WIDTH-1:0] reg_op
    );

    always@(posedge clk) 
    begin
    	if(master_rst)
    		reg_op <= 0;
    	else 
        begin
            if(ce) 
            begin
		   	  if(rst_m) begin
		    	 reg_op <=0;
		      end
		      else begin
		    	 reg_op <= data_in;
			 end
		    end
		end
	end
endmodule