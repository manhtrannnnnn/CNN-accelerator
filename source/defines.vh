// Global parameters definitions
`ifndef _DEFINES_VH_
`define _DEFINES_VH_

// Data width for processing
`define DATA_WIDTH      8   // Width of data path in bits

// Network architecture parameters
`define INPUT_SIZE      28   // Input image width/height
`define KERNEL_SIZE     3   // Convolution kernel size
`define PADDING         0   // Padding size
`define STRIDE          1   // Stride value for convolution

// Activation function selector
`define ACTIVATION_TYPE       1'b1  // 0: tanh, 1: relu
`define TANH_LUT_DEPTH 256   // LUT depth for tanh function
// Pooling layer type
`define POOL_SIZE      2   // Pooling window size
`define POOL_TYPE      1'b1  // 0: average pooling, 1: max pooling

`endif
