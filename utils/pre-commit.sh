#!/bin/bash

FILE_PATTERN="secret_*.yml"
ENCRYPTED_PATTERN="\$ANSIBLE_VAULT"

find . -name "secure*.yml" | while IFS= read -r file; do
    echo $file
    if ! grep -q "^${ENCRYPTED_PATTERN}" $file; then
        echo "ERROR: Vault file $file is not encrypted. Commit cannot proceed"
        exit 1
    fi
done