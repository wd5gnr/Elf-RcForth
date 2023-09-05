#!/bin/bash
# Sample build script
#rcasm -v -h -l -x -d1802 -DELF2K -DSTGROM forth.asm >forth.lst
asm02 -L -i -DELF2K -DSTGROM forth.asm

