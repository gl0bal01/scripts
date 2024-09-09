#!/bin/bash

# gl0bal01 - SQLyog Password Decoder Script
# -----------------------------------------
# Description:
# This script decodes encrypted SQLyog passwords stored in configuration files. 
# It is useful for recovering passwords from SQLyog configuration files when you have forgotten them.
#
# Example usage:
# ./sqlyog-decode-pwd.sh 5f4dcc3b5aa765d61d8327deb882cf99
# Output: decoded_password

# Function to display usage information
usage() {
    echo "Usage: $0 encrypted_password"
    exit 1
}

# Function to decode passwords from: USERDIR\Application Data\SQLyog\sqlyog.ini
decode_password() {
    local encoded=$1
    
    # Decode base64, convert to hex, and process each byte
    local decoded=$(echo "$encoded" | base64 -d | xxd -p -c1 | while read byte; do
        # Rotate left by 1 bit (equivalent to rotating left by 8 in the original script)
        # (byte << 1 & 0xff) shifts left and masks to keep within byte range
        # (byte >> 7) brings the leftmost bit to the rightmost position
        # The | operator combines these two operations
        printf "%02x" $(( (0x$byte << 1 & 0xff) | (0x$byte >> 7) ))
    done)
    
    # Convert the processed hex back to ASCII
    echo -n "$decoded" | xxd -r -p
}

# Check if exactly one argument is provided
if [ $# -ne 1 ]; then
    usage
fi

# Call the decode_password function with the provided argument
decode_password "$1"

# Exit successfully
exit 0
