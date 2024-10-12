#!/bin/bash

# gl0bal01 - Word Permutator Script
# ---------------------------------
# Description:
# This script generates permutations of words and their subsets.
# It can take words as direct input or from a file.
# Options:
#   -f <file>: Read words from a file
#   -s <separator>: Specify a separator for output (default: no separator)

# Function to generate permutations of given words
generate_permutations() {
    local items=("$@")
    local n=${#items[@]}

    if [ $n -eq 0 ]; then
        echo ""
    elif [ $n -eq 1 ]; then
        echo "${items[0]}"
    else
        for ((i=0; i<n; i++)); do
            local remaining=("${items[@]:0:i}" "${items[@]:i+1}")
            while IFS= read -r perm; do
                echo "${items[i]}${separator}$perm"
            done < <(generate_permutations "${remaining[@]}")
        done
    fi
}

# Function to generate all subsets
generate_subsets() {
    local items=("$@")
    local n=${#items[@]}
    local total=$((2**n))

    for ((i=1; i<total; i++)); do
        local subset=()
        for ((j=0; j<n; j++)); do
            if (( (i & (1<<j)) != 0 )); then
                subset+=("${items[j]}")
            fi
        done
        if [ ${#subset[@]} -ge 2 ]; then
            echo "${subset[@]}"
        fi
    done
}

# Initialize variables
separator=""
file_input=""

# Parse command-line options
while getopts "f:s:" opt; do
    case $opt in
        f) file_input="$OPTARG" ;;
        s) separator="$OPTARG" ;;
        \?) echo "Invalid option: -$OPTARG" >&2; exit 1 ;;
    esac
done

# Shift the parsed options
shift $((OPTIND - 1))

# Read words from file or command-line arguments
if [ -n "$file_input" ]; then
    if [ -f "$file_input" ]; then
        mapfile -t words < "$file_input"
    else
        echo "Error: File not found" >&2
        exit 1
    fi
else
    words=("$@")
fi

# Validate input
if [ ${#words[@]} -eq 0 ] || [ ${#words[@]} -gt 6 ]; then
    echo "Error: Please provide 1 to 6 words as arguments or use -f with a file" >&2
    exit 1
fi

# Generate and print permutations of all words
# echo "Permutations of all words:"
generate_permutations "${words[@]}"

# Generate and print permutations of subsets
# echo -e "\nPermutations of subsets:"
generate_subsets "${words[@]}" | while read -r subset; do
    IFS=' ' read -ra subset_array <<< "$subset"
    generate_permutations "${subset_array[@]}"
done
