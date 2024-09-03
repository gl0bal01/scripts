#!/usr/bin/env bash

# Set strict mode
set -euo pipefail

# Function to escape JSON string
json_escape() {
    local s="$1"
    s="${s//\\/\\\\}"
    s="${s//\"/\\\"}"
    s="${s//$'\n'/\\n}"
    s="${s//$'\r'/\\r}"
    s="${s//$'\t'/\\t}"
    printf "%s" "$s"
}

# Function to analyze redirect chain
analyze_redirect_chain() {
    local url=$1
    local json_output=$2
    local output=$(curl -s -L -o /dev/null -w "%{http_code} %{url_effective}\n" -D - "$url")
    
    # Extract redirect chain
    local redirect_chain=$(echo "$output" | sed -n 's/^HTTP\/[0-9.]* \([0-9]*\).*$/\1/p; s/^[Ll]ocation: *//p' | 
        paste -d ' ' - - | sed '$ d')

    # Extract final destination
    local final_destination=$(echo "$output" | tail -n 1)

    if [ "$json_output" = true ]; then
        # Prepare JSON output
        local json_redirect_chain=""
        while IFS= read -r line; do
            local status=$(echo "$line" | cut -d' ' -f1)
            local redirect_url=$(echo "$line" | cut -d' ' -f2-)
            local escaped_url=$(json_escape "$redirect_url")
            json_redirect_chain+=$(printf '{"status": "%s", "url": "%s"},' "$status" "$escaped_url")
        done <<< "$redirect_chain"
        json_redirect_chain=${json_redirect_chain%,}

        local final_status=$(echo "$final_destination" | cut -d' ' -f1)
        local final_url=$(echo "$final_destination" | cut -d' ' -f2-)
        local escaped_final_url=$(json_escape "$final_url")
        local escaped_initial_url=$(json_escape "$url")

        echo "{"
        echo "  \"initial_url\": \"$escaped_initial_url\","
        if [ -n "$json_redirect_chain" ]; then
            echo "  \"redirect_chain\": [$json_redirect_chain],"
        else
            echo "  \"redirect_chain\": [],"
        fi
        echo "  \"final_destination\": {"
        echo "    \"status\": \"$final_status\","
        echo "    \"url\": \"$escaped_final_url\""
        echo "  }"
        echo "}"
    else
        echo "Analyzing URL: $url"
        if [ -n "$redirect_chain" ]; then
            echo -e "\nRedirect chain:"
            echo "$redirect_chain"
        fi
        echo -e "\nFinal destination:"
        echo "$final_destination"
    fi
}

# Main execution
main() {
    local json_output=false

    # Parse command line options
    while getopts ":j" opt; do
        case ${opt} in
            j )
                json_output=true
                ;;
            \? )
                echo "Invalid option: $OPTARG" 1>&2
                ;;
        esac
    done
    shift $((OPTIND -1))

    # Check if a URL is provided as an argument
    if [ $# -eq 0 ]; then
        echo "Usage: $0 [-j] <URL>"
        echo "  -j    Output in JSON format"
        exit 1
    fi

    # Call the function with the provided URL and json_output flag
    analyze_redirect_chain "$1" "$json_output"
}

# Run the main function
main "$@"
