#!/bin/bash
# The command "CR" stands for "Compile and Run" and is a script to comile and run a C++ program.:
# "cr filename" (without extension)
# Example: "cr input_text" (for input_text.cpp)


if [ "$#" -ne 1 ]; then
    echo "Usage: $0 filename (without extension)"
    exit 1
fi

filename=$1

# Compile the C++ program
# "o2" -> optimization level 2
# "o3" -> optimization level 3

g++ -Wall -std=c++17 -O3 -o $filename $filename.cpp
if [ $? -eq 0 ]; then
    echo "Compilation successful. Running..."
    ./$filename
else
    echo "Compilation failed."
fi
