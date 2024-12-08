`timescale 1ns / 1ps

module control_logic2 #(
    parameter M = 9'h004,   // Total number of rows in the input
    parameter P = 9'h002    // Pooling size (both width and height)
)(
    input clk,             
    input master_rst,       
    input ce,            
    output reg [1:0] sel, 
    output reg rst_m,     
    output reg op_en,      
    output reg load_sr,    
    output reg global_rst,  
    output reg end_op       
);
    integer row_count = 0;         
    integer col_count = 0;        
    integer count = 0;         
    integer nbgh_row_count = 0;   

    // Always block for control signals
    always @(posedge clk) begin
        if (master_rst) begin
            sel <= 2'b00;
            load_sr <= 0;
            rst_m <= 0;
            op_en <= 0;
            global_rst <= 1;
            end_op <= 0;
        end else begin
            // Case 4: End of neighbourhood in the last row
            if (((col_count + 1) % P != 0) && (row_count == P - 1) && 
                (col_count == P * count + (P - 2)) && ce) begin
                op_en <= 1;
            end else begin
                op_en <= 0;
            end

            if (ce) begin
                // Case 5: End of last neighbourhood of the last row
                if (nbgh_row_count == M / P) begin
                    end_op <= 1;
                end else begin
                    end_op <= 0;
                end

                // Reset the entire module when the last column and row are reached
                if (((col_count + 1) % P != 0) && (col_count == M - 2) && 
                    (row_count == P - 1)) begin
                    global_rst <= 1;
                end else begin
                    global_rst <= 0;
                end

                // Case 3: Reset max register at the end of the neighbourhood
                if ((((col_count + 1) % P == 0) && (count != M / P - 1) && 
                    (row_count != P - 1)) || ((col_count == M - 1) && 
                    (row_count == P - 1))) begin
                    rst_m <= 1;
                end else begin
                    rst_m <= 0;
                end

                // Selector logic
                if (((col_count + 1) % P != 0) && (col_count == M - 2) && 
                    (row_count == P - 1)) begin
                    sel <= 2'b10;
                end else if ((((col_count) % P == 0) && (count == M / P - 1) && 
                            (row_count != P - 1)) || 
                           (((col_count) % P == 0) && (count != M / P - 1) && 
                            (row_count == P - 1))) begin
                    sel <= 2'b01;
                end else begin
                    sel <= 2'b00;
                end

                // Case 2: Load the shift register
                if ((((col_count + 1) % P == 0) && (count == M / P - 1)) || 
                    (((col_count + 1) % P == 0) && (count != M / P - 1))) begin
                    load_sr <= 1;
                end else begin
                    load_sr <= 0;
                end
            end
        end
    end

    // Always block for counters
    always @(posedge clk) begin
        if (master_rst) begin
            row_count <= 0;
            col_count <= 32'hffffffff;
            count <= 32'hffffffff;
            nbgh_row_count <= 0;
        end else if (ce) begin
            if (global_rst) begin
                row_count <= 0;
                col_count <= 0;
                count <= 0;
                nbgh_row_count <= nbgh_row_count + 1;
            end else begin
                // Update column, row, and neighbourhood counters
                if (((col_count + 1) % P == 0) && (count == M / P - 1) && 
                    (row_count != P - 1)) begin
                    col_count <= 0;
                    row_count <= row_count + 1;
                    count <= 0;
                end else begin
                    col_count <= col_count + 1;
                    if (((col_count + 1) % P == 0) && (count != M / P - 1)) begin
                        count <= count + 1;
                    end
                end
            end
        end
    end
endmodule
