module tanh_activation #(
    parameter DATA_WIDTH = 8,      // Width of input (int8)
    parameter addrWidth = 256      // Depth of LUT
)(
    input  signed [DATA_WIDTH-1:0] data_in,   // Input int8
    output signed [DATA_WIDTH-1:0] data_out  // Output int8 (tanh result)
);

    // ROM for tanh LUT
    reg signed [DATA_WIDTH-1:0] tanh_lut [0:addrWidth-1];

    // Initialize LUT from file
    initial begin
        $readmemb("tanh_lut.mem", tanh_lut);
    end

    // Map input to LUT address
    wire [7:0] addr = data_in + 128;  // Shift input to positive range (0 to 255)

    // Output from LUT
    assign data_out = tanh_lut[addr];

endmodule
