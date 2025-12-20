#!/bin/bash

# Check if a filename was provided
if [ -z "$1" ]; then
    echo "Usage: $0 <filename.yaml>"
    exit 1
fi

FILE_NAME=$1

# Generate the output filename by inserting '-enc' before the extension
if [[ "$FILE_NAME" == *.* ]]; then
    OUTPUT_FILE="${FILE_NAME%.*}-enc.${FILE_NAME##*.}"
else
    OUTPUT_FILE="${FILE_NAME}-enc"
fi

# Path to your age key file (adjust if yours is stored elsewhere)
# SOPS usually looks here by default on Linux
AGE_KEY_FILE="${HOME}/.config/sops/age/keys.txt"

# Ensure the key file exists
if [ ! -f "$AGE_KEY_FILE" ]; then
    echo "Error: age key file not found at $AGE_KEY_FILE"
    echo "Generate one using: age-keygen -o $AGE_KEY_FILE"
    exit 1
fi

# Extract the public key from your age identity file
# SOPS requires the recipient (public key) to encrypt
PUBLIC_KEY=$(grep -oP "public key: \K(.*)" "$AGE_KEY_FILE")

echo "Encrypting $FILE_NAME to $OUTPUT_FILE using age..."

# Encrypt the file
# --encrypt: perform encryption
# --age: specify the age public key recipient
# --output: write the result to the new filename instead of overwriting the original
sops --encrypt --age "$PUBLIC_KEY" --output "$OUTPUT_FILE" "$FILE_NAME"

if [ $? -eq 0 ]; then
    echo "Successfully encrypted $FILE_NAME to $OUTPUT_FILE"
else
    echo "Encryption failed."
    exit 1
fi

