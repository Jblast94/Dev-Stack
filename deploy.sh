#!/bin/bash
set -e

echo "Setting up dev stack environment..."

# Install required packages
echo "Installing dependencies..."
sudo apt-get update
sudo apt-get install -y \
    apt-transport-https \
    ca-certificates \
    curl \
    gnupg \
    lsb-release

# Install Docker if not installed
if ! command -v docker &> /dev/null; then
    echo "Installing Docker..."
    curl -fsSL https://get.docker.com -o get-docker.sh
    sudo sh get-docker.sh
    sudo usermod -aG docker $USER
    rm get-docker.sh
fi

# Install Docker Compose if not installed
if ! command -v docker compose &> /dev/null; then
    echo "Installing Docker Compose..."
    sudo curl -L "https://github.com/docker/compose/releases/latest/download/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
    sudo chmod +x /usr/local/bin/docker-compose
fi

# Create required directories
echo "Creating directories..."
mkdir -p data/{ollama,openwebui,minio,portainer,traefik}

# Prompt for email address
read -p "Enter your email address for Let's Encrypt certificates: " EMAIL

# Replace email in docker-compose.yml
sed -i "s/your-email@example.com/$EMAIL/" docker-compose.yml

# Create .env file for environment variables
cat > .env << EOF
N8N_BASIC_AUTH_USER=admin
N8N_BASIC_AUTH_PASSWORD=change_me_immediately
MINIO_ROOT_USER=minioadmin
MINIO_ROOT_PASSWORD=change_me_immediately
EOF

# Set correct permissions
sudo chown -R 1000:1000 data/

echo "Starting services..."
docker compose up -d

echo "Setup complete! Please wait a few minutes for all services to initialize."
echo "
Access your services at:
- Traefik Dashboard: https://traefik.myn8n.art
- Ollama API: https://llm.myn8n.art
- OpenWebUI: https://chat.myn8n.art
- n8n: https://n8n.myn8n.art
- MinIO Console: https://s3-console.myn8n.art
- Adminer: https://db.myn8n.art
- Portainer: https://docker.myn8n.art

Important:
1. Update your DNS records to point these domains to your server's IP
2. Change default passwords in Portainer and MinIO console
3. Configure n8n credentials in the .env file
"
