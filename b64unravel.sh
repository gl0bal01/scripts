#!/bin/bash

# gl0bal01 - b64unravel
# ---------------------
# Description:
# Iteratively decodes base64 content until no further decoding is possible

if [ $# -eq 0 ]; then
    echo "Usage: $0 <input_file>"
    exit 1
fi

input_file=$1
content=$(cat "$input_file")
last_valid_content="$content"
iteration=0

while true; do
    iteration=$((iteration + 1))
    decoded_content=$(echo "$content" | base64 -d 2>/dev/null)

    # Check if decoding was successful
    if [ $? -ne 0 ]; then
        echo "Decoding stopped at iteration $iteration. Outputting last valid decoded content."
        echo "$last_valid_content"
        break
    fi

    last_valid_content="$decoded_content"
    content="$decoded_content"
done
