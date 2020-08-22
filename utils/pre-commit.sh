#!/bin/bash

FILE_PATTERN="secure*.yml"
ENCRYPTED_PATTERN="\$ANSIBLE_VAULT"

find . -name "$FILE_PATTERN" | while IFS= read -r file; do
    echo $file
    if ! grep -q "^${ENCRYPTED_PATTERN}" $file; then
        echo "ERROR: Vault file $file is not encrypted. Commit cannot proceed"
        exit 1
    fi
done