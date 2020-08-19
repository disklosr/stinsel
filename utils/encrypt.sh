# A helper script to encrypt all files with pattern "secure_*.yml" using Ansible vault
# Usage: ./encrypt.sh

find . -name "secure_*.yml" | xargs -n 1 ansible-vault encrypt $1