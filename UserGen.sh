#!/bin/bash

# gl0bal01 - Username Generator Script
# ------------------------------------
# Description:
# This script generates various username combinations based on the provided first name and last name.
# Optionally, the user can provide a list of separators (e.g., '_', '-', '.') to create more combinations.
# If no separators are provided, the default separator is a period ('.').

if [ "$#" -lt 2 ] || [ "$#" -gt 3 ]; then
    echo "Usage: $0 <first_name> <last_name> [separator_list]"
    echo "Example: $0 John Doe _,-,."
    exit 1
fi

first_name=$1
last_name=$2
separator_list=${3:-"."}  # Default to a single separator "."

generate_usernames() {
    local first_initial="${first_name:0:1}"
    local last_initial="${last_name:0:1}"
    local first_three="${first_name:0:3}"
    local last_three="${last_name:0:3}"

    echo "${first_name}${last_name}"
    echo "${last_name}${first_name}"
    echo "${first_initial}${last_name}"
    echo "${last_name}${first_initial}"
    echo "${first_three}${last_three}"
    echo "${last_three}${first_three}"

    IFS=',' read -ra separators <<< "$separator_list"

    for separator in "${separators[@]}"; do
        echo "${first_name}${separator}${last_name}"
        echo "${last_name}${separator}${first_name}"
        echo "${first_name}${separator}${last_initial}"
        echo "${last_name}${separator}${first_initial}"
        echo "${first_three}${separator}${last_three}"
        echo "${last_three}${separator}${first_three}"
    done
}

generate_usernames
