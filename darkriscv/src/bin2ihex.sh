#!/bin/bash

ADDR=0
SRC=four.bin;DST=four.hex
#dd if=$SRC of=swapped.bin bs=4 count=$(($(stat -c%s $SRC)/4)) conv=swab;SRC=swapped.bin
xxd -p $SRC | sed 's/\(..\)\(..\)\(..\)\(..\)/\4\3\2\1/g' | xxd -r -p > swapped.bin;SRC=swapped.bin
objcopy -I binary -O ihex --change-addresses=$ADDR $SRC $DST
