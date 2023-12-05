#!/bin/bash

# Check if a file argument is provided
if [ "$#" -ne 1 ]; then
    echo "Usage: $0 <file>"
    exit 1
fi

# The file to be processed
FILE=$1

# Check if the file exists
if [ ! -f "$FILE" ]; then
    echo "File not found: $FILE"
    exit 1
fi

# Calculate the SHA-256 hash of the file
HASH=$(sha256sum "$FILE" | cut -d ' ' -f 1)

# Use Python for base58 encoding
ENCODED=$(python3 -c "import base58; print(base58.b58encode(bytes.fromhex('$HASH')).decode())")

echo "Base58 Encoded SHA-256: $ENCODED"
