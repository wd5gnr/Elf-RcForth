#!/bin/bash
# Sample build script
#rcasm -v -h -l -x -d1802 -DELF2K -DSTGROM forth.asm >forth.lst
asm02 -L -b -DELF2K -DELFOS forth.asm
cp forth.bin elfos/forth.bin

