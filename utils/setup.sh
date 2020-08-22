#!/bin/bash

# A helper script to setup a fresh new server
# Usage: ./setup.sh host_alias

set -e # Stop at first error

echo "Setting up server $1 for first use..."
./utils/run.sh $1 00 --ask-pass -e "ansible_port=22" -e "ansible_user=root"
./utils/run.sh $1 01
./utils/run.sh $1 03
./utils/run.sh $1 04
./utils/run.sh $1 05
echo "Finished setting up server $1"