#!/bin/bash

# Move into the ansible directory
cd "$(dirname "$0")"

KEY_FILE="key.pem"

# Function to validate SSH key presence
function check_key {
  if [ ! -f "$KEY_FILE" ]; then
    echo "❌ ERROR: '$KEY_FILE' not found in $(pwd)"
    exit 1
  fi
  chmod 400 "$KEY_FILE"
}

# Deploy Backend
read -p "Enter the public IP address of your BACKEND EC2 instance: " backend_ip

check_key

echo "[web]" > inventory_backend.ini
echo "$backend_ip ansible_user=ubuntu ansible_ssh_private_key_file=$(pwd)/$KEY_FILE" >> inventory_backend.ini

echo -e "\n✅ inventory_backend.ini created:"
cat inventory_backend.ini

echo -e "\n🚀 Running backend Ansible playbook..."
ansible-playbook -i inventory_backend.ini backend.yml

mkdir -p frontend  # Ensure folder exists
cat > frontend/.env <<EOF
BACKEND_URL=http://$backend_ip:8000
EOF

echo -e "\n✅ Generated frontend/.env with backend URL:"
cat frontend/.env

# Deploy Frontend
read -p "Enter the public IP address of your FRONTEND EC2 instance: " frontend_ip

check_key

echo "[web]" > inventory_frontend.ini
echo "$frontend_ip ansible_user=ubuntu ansible_ssh_private_key_file=$(pwd)/$KEY_FILE" >> inventory_frontend.ini

echo -e "\n✅ inventory_frontend.ini created:"
cat inventory_frontend.ini

echo -e "\n🚀 Running frontend Ansible playbook..."
ansible-playbook -i inventory_frontend.ini frontend.yml

