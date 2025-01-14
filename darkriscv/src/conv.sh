awk '{print substr($0, 7, 2) substr($0, 5, 2) substr($0, 3, 2) substr($0, 1, 2)}' darksocv.mem | xxd -r -p > darksocv.bin
