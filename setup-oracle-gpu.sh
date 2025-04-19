#!/bin/bash
set -e

echo "Setting up Oracle Cloud GPU instance for Orpheus TTS..."

# Install system dependencies
echo "Installing system dependencies..."
sudo apt-get update
sudo apt-get install -y \
    apt-transport-https \
    ca-certificates \
    curl \
    gnupg \
    lsb-release \
    git

# Install NVIDIA drivers
echo "Installing NVIDIA drivers for A10..."
sudo apt-get install -y nvidia-driver-535-server
sudo nvidia-smi

# Configure GPU settings for optimal performance
echo "Configuring GPU settings..."
sudo nvidia-smi -pm 1  # Enable persistent mode
sudo nvidia-smi --auto-boost-default=0  # Disable auto boost
sudo nvidia-smi -ac 1215,1410  # Set optimal memory and graphics clocks

# Install Docker
echo "Installing Docker..."
curl -fsSL https://get.docker.com -o get-docker.sh
sudo sh get-docker.sh

# Install NVIDIA Container Toolkit
echo "Installing NVIDIA Container Toolkit..."
distribution=$(. /etc/os-release;echo $ID$VERSION_ID)
curl -s -L https://nvidia.github.io/nvidia-docker/gpgkey | sudo apt-key add -
curl -s -L https://nvidia.github.io/nvidia-docker/$distribution/nvidia-docker.list | sudo tee /etc/apt/sources.list.d/nvidia-docker.list
sudo apt-get update
sudo apt-get install -y nvidia-container-toolkit
sudo systemctl restart docker

# Create models directory and download Orpheus model
echo "Setting up Orpheus model..."
mkdir -p models
cd models
echo "Downloading Orpheus Q4 model (this may take a while)..."
curl -L https://huggingface.co/lex-au/Orpheus-3b-FT-Q4_K_M/resolve/main/Orpheus-3b-FT-Q4_K_M.gguf -o Orpheus-3b-FT-Q4_K_M.gguf
cd ..

# Configure OpenWebUI for TTS
echo "Configuring OpenWebUI for TTS..."
cat > openwebui-tts-config.json << EOF
{
    "tts": {
        "provider": "openai",
        "openai": {
            "apiBaseUrl": "https://tts.myn8n.art/v1",
            "apiKey": "not-needed",
            "voice": "tara",
            "model": "tts-1"
        }
    }
}
EOF

echo "Setup complete! Now you can:"
echo "1. Start the stack with: docker compose up -d"
echo "2. Import the TTS configuration in OpenWebUI Admin Panel"
echo "3. Access services at:"
echo "   - OpenWebUI: https://chat.myn8n.art"
echo "   - Orpheus TTS: https://tts.myn8n.art"
echo "   - Llama.cpp Server: https://llm-server.myn8n.art"
