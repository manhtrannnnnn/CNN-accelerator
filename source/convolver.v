`timescale 1ns/1ps

module convolver #(
    parameter DATA_WIDTH = 8,
    parameter INPUT_SIZE = 28,
    parameter KERNEL_SIZE = 3,
    parameter STRIDE = 1
) (
    input clk, ce, global_rst, 
    input [DATA_WIDTH-1:0] myInput,
    input [(KERNEL_SIZE*KERNEL_SIZE)*DATA_WIDTH-1:0] weight,
    input [DATA_WIDTH-1:0] bias,
    output [DATA_WIDTH-1:0] conv_op,
    output reg valid_conv, end_conv
);

    // Temporary storage for separated weights and intermediate results
    wire [DATA_WIDTH-1:0] weight_tmp [KERNEL_SIZE*KERNEL_SIZE-1:0];
    wire [DATA_WIDTH-1:0] tmp [KERNEL_SIZE*KERNEL_SIZE+1:0];

    // Extract weights from the input vector
    generate 
        genvar j;
        for (j = 0; j < KERNEL_SIZE*KERNEL_SIZE; j = j + 1) begin
            assign weight_tmp[j][DATA_WIDTH-1:0] = weight[j*DATA_WIDTH +: DATA_WIDTH];
        end
    endgenerate

    assign tmp[0] = {DATA_WIDTH{1'b0}};
    // Implement MAC (Multiply-Accumulate) for convolution
    generate 
        genvar i;
        for (i = 0; i < KERNEL_SIZE*KERNEL_SIZE; i = i + 1) begin: MAC
            if ((i + 1) % KERNEL_SIZE == 0) begin
                // Special case: Shift register for the last column of each row
                if (i == KERNEL_SIZE*KERNEL_SIZE-1) begin
                    mac_manual #(.DATA_WIDTH(DATA_WIDTH)) mac (
                        .clk(clk),
                        .ce(ce),
                        .rst(global_rst),
                        .a(myInput),
                        .b(weight_tmp[i]),
                        .tmp(tmp[i]),
                        .data_out(tmp[i+1])
                    );
                assign conv_op = tmp[i+1] + bias;
                end else begin
                    wire [DATA_WIDTH-1:0] tmp2;
                    mac_manual #(.DATA_WIDTH(DATA_WIDTH)) mac (
                        .clk(clk),
                        .ce(ce),
                        .rst(global_rst),
                        .a(myInput),
                        .b(weight_tmp[i]),
                        .tmp(tmp[i]),
                        .data_out(tmp2)
                    );
                    shift_register #(.DATA_WIDTH(DATA_WIDTH), .size(INPUT_SIZE-KERNEL_SIZE)) sr (
                        .clk(clk),
                        .ce(ce),
                        .rst(global_rst),
                        .data_in(tmp2),
                        .data_out(tmp[i+1])
                    );
                end
            end else begin
                mac_manual #(.DATA_WIDTH(DATA_WIDTH)) mac (
                    .clk(clk),
                    .ce(ce),
                    .rst(global_rst),
                    .a(myInput),
                    .b(weight_tmp[i]),
                    .tmp(tmp[i]),
                    .data_out(tmp[i+1])
                );
            end
        end
    endgenerate

    // Row, column, and cycle counters to track convolution progress
    reg [$clog2(INPUT_SIZE):0] row_counter = 0;
    reg [$clog2(INPUT_SIZE):0] col_counter = 0;
    reg [$clog2(INPUT_SIZE*INPUT_SIZE):0] cycle_counter = 0;

    // Logic to control row and column counters
    always @(posedge clk) begin
        if (global_rst) begin
            row_counter <= 0;
            col_counter <= 0;
            cycle_counter <= 0;
        end else if (ce) begin
            if (col_counter + STRIDE >= INPUT_SIZE) begin
                col_counter <= 0;
                if (row_counter + STRIDE >= INPUT_SIZE) begin
                    row_counter <= 0;
                end else begin
                    row_counter <= row_counter + STRIDE;
                end
            end else begin
                col_counter <= col_counter + STRIDE;
            end
            cycle_counter <= cycle_counter + 1;
        end
    end

    // Generate `valid_conv` when at a valid convolution window
    always @(posedge clk) begin
        if (global_rst) begin
            valid_conv <= 0;
        end else if (ce) begin
            if ((row_counter >= KERNEL_SIZE-1 && row_counter < INPUT_SIZE && 
                 (row_counter - (KERNEL_SIZE-1)) % STRIDE == 0) &&
                (col_counter >= KERNEL_SIZE-1 && col_counter < INPUT_SIZE && 
                 (col_counter - (KERNEL_SIZE-1)) % STRIDE == 0)) begin
                valid_conv <= 1;
            end else begin
                valid_conv <= 0;
            end
        end
    end

    // Generate `end_conv` when the entire convolution is complete
    always @(posedge clk) begin
        if (global_rst) begin
            end_conv <= 0;
        end else if (ce && cycle_counter >= INPUT_SIZE*INPUT_SIZE) begin
            end_conv <= 1;
        end else begin
            end_conv <= 0;
        end
    end

endmodule
