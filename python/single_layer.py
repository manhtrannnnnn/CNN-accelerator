import numpy as np

# Parameters
input_size = 8  # Size of input feature map
kernel_size = 3  # Size of kernel
pool_size = 2    # Size of pooling window
stride = 1       # Stride for convolution

# Generate random input and kernel
np.random.seed(42)  # For reproducibility
input_data = np.random.randint(-4, 3, size=(input_size, input_size), dtype=np.int8) 
kernel = np.random.randint(-4, 3, size=(kernel_size, kernel_size), dtype=np.int8)

# Perform convolution
output_size = (input_size - kernel_size) // stride + 1
convo_output = np.zeros((output_size, output_size), dtype=np.int16)

for i in range(output_size):
    for j in range(output_size):
        region = input_data[i:i + kernel_size, j:j + kernel_size]
        convo_output[i, j] = np.sum(region * kernel)

# Apply ReLU activation with 8-bit signed integer handling
def relu_8bit(x):
    """ Apply ReLU and ensure output is within 8-bit signed integer range. """
    return np.clip(np.maximum(x, 0), -128, 127)

relu_output = relu_8bit(convo_output)

# Perform max pooling
pool_output_size = output_size // pool_size
pooling_output = np.zeros((pool_output_size, pool_output_size), dtype=np.int16)

for i in range(pool_output_size):
    for j in range(pool_output_size):
        region = relu_output[i * pool_size:(i + 1) * pool_size, j * pool_size:(j + 1) * pool_size]
        pooling_output[i, j] = np.max(region)

# Save results to files
# Convert input and kernel to binary strings
def to_bin(x, bits=8):
    """ Convert int8 to binary string with two's complement representation. """
    if x < 0:
        return format((1 << bits) + x, f'0{bits}b')  # Two's complement for negative numbers
    else:
        return format(x, f'0{bits}b')

binary_input = np.vectorize(lambda x: to_bin(x, 8))(input_data)  # For int8 input
binary_kernel = np.vectorize(lambda x: to_bin(x, 8))(kernel)  # For int8 kernel

# Save binary input and kernel
np.savetxt("input.txt", binary_input, fmt='%s')
np.savetxt("kernel.txt", binary_kernel, fmt='%s')

# Convert convo_output, relu_output, and pooling_output to binary and save
binary_convo_output = np.vectorize(lambda x: to_bin(x, 8))(convo_output)  # Assuming you want to store 8-bit values
np.savetxt("convo_output.txt", binary_convo_output, fmt='%s')

binary_relu_output = np.vectorize(lambda x: to_bin(x, 8))(relu_output)
np.savetxt("relu_output.txt", binary_relu_output, fmt='%s')

binary_pooling_output = np.vectorize(lambda x: to_bin(x, 8))(pooling_output)
np.savetxt("pooling_output.txt", binary_pooling_output, fmt='%s')

print("Files generated successfully:")
print("1. input.txt")
print("2. kernel.txt")
print("3. convo_output.txt")
print("4. relu_output.txt")
print("5. pooling_output.txt")