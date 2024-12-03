`timescale 1ns / 1ps

module pooler #(
    parameter M = 9'h004,                       // Input matrix size (rows/columns)
    parameter P = 9'h002,                       // Pooling window size
    parameter dataWidth = 16,                   // Data width for inputs/outputs
    parameter ptype = 1                         // Pooling type: 0 -> Average, 1 -> Max
)(
    input clk,                                  // Clock signal
    input ce,                                   // Clock enable signal
    input master_rst,                           // Master reset
    input [dataWidth-1:0] data_in,              // Input data
    output [dataWidth-1:0] data_out,            // Output data
    output valid_op,                            // Signal indicating valid output
    output end_op                               // Signal indicating all outputs are completed
);

    // Internal control signals
    wire rst_m;                               
    wire load_sr;                              
    wire global_rst;                            
    wire [1:0] sel;                            
    // Internal data signals
    wire [dataWidth-1:0] comp_op;              
    wire [dataWidth-1:0] sr_op;                
    wire [dataWidth-1:0] max_reg_op;            
    wire [dataWidth-1:0] div_op;               
    wire [dataWidth-1:0] mux_out;             

    // Instantiate the control logic to generate control signals
    control_logic2 #(.M(M), .P(P)) control_logic_inst (
        .clk(clk),
        .master_rst(master_rst),
        .ce(ce),
        .sel(sel),
        .rst_m(rst_m),
        .op_en(valid_op),
        .load_sr(load_sr),
        .global_rst(global_rst),
        .end_op(end_op)
    );

    // Comparator to compare the current input and the selected previous value
    comparator2 #(
        .dataWidth(dataWidth),
        .ptype(ptype)
    ) comparator_inst (
        .ce(ce),
        .in1(data_in),
        .in2(mux_out),
        .comp_op(comp_op)
    );

    // Max register to store the maximum value (or intermediate values)
    max_reg #(
        .N(dataWidth)
    ) max_reg_inst (
        .clk(clk),
        .ce(ce),
        .data_in(comp_op),
        .rst_m(rst_m),
        .master_rst(master_rst),
        .reg_op(max_reg_op)
    );

    // Shift register for storing intermediate values for row-wise pooling
    shift_register #(
        .dataWidth(dataWidth),
        .size(M / P)
    ) shift_register_inst (
        .clk(clk),
        .ce(load_sr),
        .rst(global_rst && master_rst),
        .data_in(comp_op),
        .data_out(sr_op)
    );

    // Multiplexer to select between shift register output and max register output
    input_mux #(
        .dataWidth(dataWidth)
    ) mux_inst (
        .in1(sr_op),           
        .in2(max_reg_op),     
        .sel(sel),             
        .op(mux_out)      
    );

    assign div_op = max_reg_op / (P * P);
    // Output data selection: max value for max pooling or scaled sum for average pooling
    assign data_out = ptype ? max_reg_op : div_op;

endmodule
