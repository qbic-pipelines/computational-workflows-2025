#!/usr/bin/env python3

input_str = "Hello World"
block_size = 4
out_name = "h_w"

# Split string into chunks
chunks = [input_str[i:i+block_size] for i in range(0, len(input_str), block_size)]

# Write each chunk to a separate file
for i, chunk in enumerate(chunks):
    with open(f"chunk_{out_name}_{i+1}.txt", "w") as f:
        f.write(chunk)
