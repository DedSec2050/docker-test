#!/bin/bash

# Move into the ansible directory
cd "$(dirname "$0")"

# Prompt user for EC2 public IP
read -p "Enter the public IP address of your EC2 instance: " ec2_ip

# Define SSH key name (must be in the same directory)
KEY_FILE="key.pem"

# Check key exists
if [ ! -f "$KEY_FILE" ]; then
  echo "❌ ERROR: '$KEY_FILE' not found in $(pwd)"
  exit 1
fi

# Set correct permissions
chmod 400 "$KEY_FILE"

# Write inventory.ini
echo "[web]" > inventory.ini
echo "$ec2_ip ansible_user=ubuntu ansible_ssh_private_key_file=$(pwd)/$KEY_FILE" >> inventory.ini

echo -e "\n✅ inventory.ini created:"
cat inventory.ini
