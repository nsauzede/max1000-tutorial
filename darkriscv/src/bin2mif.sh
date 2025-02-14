#!/bin/bash

WORD=32
SRC=four.bin;DST=four.mif
srec_cat $SRC -binary -byte-swap 4 -o $DST -mif $WORD
