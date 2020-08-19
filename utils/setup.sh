#!/bin/bash

# A helper script to setup a fresh new server
# Usage: ./setup.sh host_alias

set -e # Stop at first error

echo "Setting up server $1 for first use..."
./utils/run.sh $1 00-create-user --ask-pass
./utils/run.sh $1 01-secure-sshd
./utils/run.sh $1 03-install-packages
./utils/run.sh $1 04-setup-firewall
./utils/run.sh $1 06-configure-docker
echo "Finished setting up server $1"