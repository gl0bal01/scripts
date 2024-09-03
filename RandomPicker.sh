#!/bin/bash

# Function to generate a random integer within a specified range
generate_random_int() {
    local min=$1
    local max=$2
    local range=$((max - min + 1))
    if ((range < 0)); then
        echo "Error: Invalid range" >&2
        exit 1
    fi
    random_int=$(od -An -N4 -tu4 /dev/urandom | tr -d ' ')
    echo $((min + (random_int % range)))
}

# Check if at least two arguments are provided
if [[ $# -lt 2 ]]; then
    echo "Usage: $0 <min> <max> [count]"
    exit 1
fi

# Parse command line arguments
min=$1
max=$2
count=${3:-1}

# Generate and output random numbers
for ((i = 0; i < count; i++)); do
    generate_random_int "$min" "$max"
done
