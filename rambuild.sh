#!/bin/bash
# Sample build script
export RCASM=/home/alw/projects/embedded/1802/rcasm/rcasm
export RCASM_DIR=/home/alw/projects/embedded/1802/rcasm/
rcasm -v -h -l -x -d1802 -DRAM forth.asm |tee forth.lst
