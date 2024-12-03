import numpy as np

# Parameters
input_size = 28  # Size of input feature map
kernel_size = 3  # Size of kernel
pool_size = 2    # Size of pooling window
stride = 1       # Stride for convolution

# Generate random input and kernel
np.random.seed(42)  # For reproducibility
input_data = np.random.randint(-64, 63, size=(input_size, input_size), dtype=np.int8) 
kernel = np.random.randint(-64, 63, size=(kernel_size, kernel_size), dtype=np.int8)

# Perform convolution
output_size = (input_size - kernel_size) // stride + 1
convo_output = np.zeros((output_size, output_size), dtype=np.int16)

for i in range(output_size):
    for j in range(output_size):
        region = input_data[i:i + kernel_size, j:j + kernel_size]
        convo_output[i, j] = np.sum(region * kernel)

# Apply ReLU activation
relu_output = np.maximum(convo_output, 0)

# Perform max pooling
pool_output_size = output_size // pool_size
pooling_output = np.zeros((pool_output_size, pool_output_size), dtype=np.int16)

for i in range(pool_output_size):
    for j in range(pool_output_size):
        region = relu_output[i * pool_size:(i + 1) * pool_size, j * pool_size:(j + 1) * pool_size]
        pooling_output[i, j] = np.max(region)

# Save results to files
# Convert input and kernel to binary strings
binary_input = np.vectorize(lambda x: format(x & 0xFF, '08b'))(input_data)  # For int8 input
binary_kernel = np.vectorize(lambda x: format(x & 0xFF, '08b'))(kernel)  # For signed kernel

# Save binary input and kernel
np.savetxt("input.txt", binary_input, fmt='%s')
np.savetxt("kernel.txt", binary_kernel, fmt='%s')

# Convert convo_output to binary and save
binary_convo_output = np.vectorize(lambda x: format(x & 0xFF, '08b'))(convo_output)
np.savetxt("convo_output.txt", binary_convo_output, fmt='%s')

# Save ReLU output in decimal
np.savetxt("relu_output.txt", relu_output, fmt='%s')

# Save pooling output in decimal
np.savetxt("pooling_output.txt", pooling_output, fmt='%s')

print("Files generated successfully:")
print("1. input.txt")
print("2. kernel.txt")
print("3. convo_output.txt")
print("4. relu_output.txt")
print("5. pooling_output.txt")