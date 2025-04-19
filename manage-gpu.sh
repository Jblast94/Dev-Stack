#!/bin/bash
set -e

# GPU instance management script
GPU_COMPOSE_FILE="docker-compose.gpu.yml"

case "$1" in
  "attach")
    echo "Creating GPU compose file..."
    cat > $GPU_COMPOSE_FILE << EOF
version: '3.8'

services:
  ollama:
    deploy:
      resources:
        reservations:
          devices:
            - driver: nvidia
              count: all
              capabilities: [gpu]
    environment:
      - NVIDIA_VISIBLE_DEVICES=all

  # Add any other services that need GPU access
EOF
    
    echo "Merging GPU configuration..."
    docker compose -f docker-compose.yml -f $GPU_COMPOSE_FILE up -d ollama
    echo "GPU attached to Ollama service"
    ;;

  "detach")
    if [ -f "$GPU_COMPOSE_FILE" ]; then
      echo "Removing GPU configuration..."
      docker compose -f docker-compose.yml up -d ollama
      rm $GPU_COMPOSE_FILE
      echo "GPU detached from services"
    else
      echo "No GPU configuration found"
    fi
    ;;

  *)
    echo "Usage: $0 {attach|detach}"
    exit 1
    ;;
esac
