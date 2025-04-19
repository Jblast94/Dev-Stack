#!/bin/bash
set -e

# 1. Update and install dependencies
sudo apt-get update
sudo apt-get install -y build-essential curl git python3-pip

# 2. Install NVIDIA drivers (skip if already installed)
echo "Checking for NVIDIA GPU..."
if ! nvidia-smi; then
  echo "Installing NVIDIA drivers..."
  sudo apt-get install -y nvidia-driver-535
  sudo reboot
fi

# 3. Install Docker
if ! command -v docker &> /dev/null; then
  echo "Installing Docker..."
  curl -fsSL https://get.docker.com -o get-docker.sh
  sudo sh get-docker.sh
fi

# 4. Install NVIDIA Container Toolkit
if ! dpkg -l | grep nvidia-container-toolkit; then
  echo "Installing NVIDIA Container Toolkit..."
  distribution=$(. /etc/os-release;echo $ID$VERSION_ID)
  curl -s -L https://nvidia.github.io/nvidia-docker/gpgkey | sudo apt-key add -
  curl -s -L https://nvidia.github.io/nvidia-docker/$distribution/nvidia-docker.list | sudo tee /etc/apt/sources.list.d/nvidia-docker.list
  sudo apt-get update
  sudo apt-get install -y nvidia-container-toolkit
  sudo systemctl restart docker
fi

# 5. (Optional) Clone your repo if not present
if [ ! -d "Orpheus-FastAPI" ]; then
  echo "Please clone your repository into this directory before running the script."
  exit 1
fi

# 6. Download Orpheus model if not present
mkdir -p models
if [ ! -f "models/Orpheus-3b-FT-Q4_K_M.gguf" ]; then
  echo "Downloading Orpheus Q4 model..."
  curl -L https://huggingface.co/lex-au/Orpheus-3b-FT-Q4_K_M/resolve/main/Orpheus-3b-FT-Q4_K_M.gguf -o models/Orpheus-3b-FT-Q4_K_M.gguf
fi

# 7. Build and launch the stack
echo "Building and launching Orpheus TTS stack..."
sudo docker compose up -d --build

echo "All done! Access your services via the mapped ports."
