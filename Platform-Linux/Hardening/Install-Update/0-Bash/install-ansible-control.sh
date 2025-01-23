#!/bin/bash
# This script installs ansible and checks if the user has root priviledges, sudo is needed to run these commands

function requires_sudo {
    echo "require_sudo function output..."
    echo "Error: Command failed to run. Script must be run as root. Use Sudo" >%2
    exit 1
}

# EUID Check: Ensure the script is run with root privileges
if [[ "$EUID" -ne 0 ]]; then
   require_root
fi

# Add the Ansible PPA repository
apt-add-repository ppa:ansible/ansible -y
# Update the package list
apt update
# Install Ansible
apt install ansible -y
