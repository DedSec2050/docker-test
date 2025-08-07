#!/bin/bash

# Install dependencies
apt update -y
apt install -y python3 python3-venv python3-pip git nodejs npm

# Run all user-level setup as the ubuntu user
sudo -u ubuntu bash <<'EOF'

cd /home/ubuntu

# Clone repo if it doesn't exist
if [ ! -d "docker-test" ]; then
  git clone https://github.com/DedSec2050/docker-test.git
fi

cd docker-test/backend

# Set up Python virtual environment
python3 -m venv venv
/home/ubuntu/docker-test/backend/venv/bin/pip install -r requirements.txt

# Run Flask backend (assuming app.py uses port 8000)
nohup /home/ubuntu/docker-test/backend/venv/bin/python3 app.py &

# Set up frontend
cd ../frontend
npm install
nohup node index.js &

EOF