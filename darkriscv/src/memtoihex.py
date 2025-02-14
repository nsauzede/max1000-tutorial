#!/bin/env python3

import sys

def compute_checksum(byte_count, address, record_type, data_bytes):
    """Compute checksum for an Intel HEX record."""
    checksum = byte_count + (address >> 8) + (address & 0xFF) + record_type
    checksum += sum(data_bytes)
    return ((~checksum + 1) & 0xFF)  # Two’s complement

def convert_raw_to_intel_hex(input_file, output_file, start_address=0x0000):
    """Convert a raw 32-bit hex file into Intel HEX format."""
    with open(input_file, "r") as infile, open(output_file, "w") as outfile:
        address = start_address

        for line in infile:
            word = line.strip()
            if not word:
                continue  # Skip empty lines
            
            word = int(word, 16)  # Convert hex string to integer
            
            # Convert to little-endian byte order (Intel HEX expects this)
            data_bytes = [
                (word & 0xFF),
                ((word >> 8) & 0xFF),
                ((word >> 16) & 0xFF),
                ((word >> 24) & 0xFF)
            ]
            
            byte_count = len(data_bytes)
            record_type = 0x00  # Data record
            checksum = compute_checksum(byte_count, address, record_type, data_bytes)
            
            # Generate Intel HEX line
            hex_line = f":{byte_count:02X}{address:04X}{record_type:02X}" + "".join(f"{b:02X}" for b in data_bytes) + f"{checksum:02X}"
            outfile.write(hex_line + "\n")

            address += 4  # Move to next 32-bit word address

        # Write EOF record
        outfile.write(":00000001FF\n")

    print(f"Conversion complete. Intel HEX file saved as: {output_file}")

# Example usage:
#convert_raw_to_intel_hex("darksocv.mem", "darksocv.hex")
convert_raw_to_intel_hex("four.mem", "four2.hex")
