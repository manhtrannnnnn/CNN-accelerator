import numpy as np

# Cấu hình fixed-point
DATA_WIDTH = 16  # Fixed-point 16-bit (Q8.8)
FRACTIONAL_BITS = 8  # Số bit thập phân

# Hàm chuyển đổi float sang fixed-point
def float_to_fixed(val, fractional_bits):
    # Chuyển đổi float sang giá trị int
    fixed_val = int(round(val * (1 << fractional_bits)))
    # Chuẩn hóa về 16-bit (dạng signed)
    if fixed_val < 0:
        fixed_val = (1 << DATA_WIDTH) + fixed_val
    return fixed_val

# Tạo LUT
lut = []
for x in range(-128, 128):  # Int8 input từ -128 đến 127
    # Normalize x từ [-128, 127] về [-1, 1]
    normalized_x = x / 128.0
    # Tính giá trị tanh
    tanh_value = np.tanh(normalized_x)
    # Chuyển sang fixed-point
    fixed_value = float_to_fixed(tanh_value, FRACTIONAL_BITS)
    # Lưu giá trị dạng nhị phân
    lut.append(f"{fixed_value:016b}")

# Ghi LUT ra file
with open("tanh_lut.mem", "w") as f:
    for value in lut:
        f.write(value + "\n")

print("File tanh_lut.mem đã được tạo thành công!")
