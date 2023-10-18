#!/bin/bash

# Check if the module name is provided as an argument
if [ $# -ne 1 ]; then
    echo "Usage: $0 <module_name>"
    exit 1
fi

module="$1"
build_folder="build/$module"

# Step 1: Create the build folder if it doesn't exist
if [ ! -d "$build_folder" ]; then
    mkdir -p "$build_folder"
    echo "Created build folder: $build_folder"
fi

# Step 2: Compile the testbench using iverilog
iverilog -Wall -o "$build_folder/${module}_tb.vvp" "testbench/$module/${module}_tb.v"

if [ $? -eq 0 ]; then
    echo "Compilation successful."

    # Step 3: Run the compiled testbench
    vvp "$build_folder/${module}_tb.vvp"
else
    echo "Compilation failed."
fi