#!/bin/bash
set -e

# Configuration
INSTANCE_TYPE="g5.xlarge"  # Default AWS instance type for ML/AI development
PRICE_THRESHOLD="1.00"     # Maximum price willing to pay per hour
REGION="us-east-1"        # Default region

# Function to check GPU utilization
check_gpu_utilization() {
    local threshold=30  # 30% utilization threshold
    local util=$(nvidia-smi --query-gpu=utilization.gpu --format=csv,noheader,nounits)
    echo "Current GPU utilization: $util%"
    if [ "$util" -lt "$threshold" ]; then
        return 0  # Low utilization
    fi
    return 1  # High utilization
}

# Function to request spot instance
request_spot_instance() {
    echo "Requesting spot instance of type $INSTANCE_TYPE..."
    # Add your cloud provider's CLI commands here
    # Example for AWS:
    # aws ec2 request-spot-instances ...
}

# Function to attach GPU to services
attach_gpu() {
    echo "Attaching GPU to services..."
    docker compose -f docker-compose.yml -f docker-compose.gpu.yml up -d \
        ollama \
        stable-diffusion \
        pytorch-server
}

# Function to setup monitoring
setup_monitoring() {
    # Configure GPU metrics collection
    docker compose up -d dcgm-exporter prometheus grafana
    
    # Wait for Grafana to be ready
    echo "Setting up GPU monitoring dashboard..."
    sleep 10
    
    # Import GPU dashboard to Grafana
    curl -X POST \
        -H "Content-Type: application/json" \
        -d @gpu-dashboard.json \
        http://admin:$GRAFANA_PASSWORD@localhost:3000/api/dashboards/db
}

case "$1" in
    "start")
        request_spot_instance
        attach_gpu
        setup_monitoring
        ;;
    "stop")
        docker compose -f docker-compose.yml -f docker-compose.gpu.yml stop \
            ollama \
            stable-diffusion \
            pytorch-server
        # Add instance termination logic here
        ;;
    "monitor")
        if check_gpu_utilization; then
            echo "GPU utilization is low, considering scale down..."
        else
            echo "GPU utilization is optimal"
        fi
        ;;
    *)
        echo "Usage: $0 {start|stop|monitor}"
        exit 1
        ;;
esac
