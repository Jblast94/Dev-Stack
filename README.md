# Dev-Stack

## Overview
This repository contains a collection of scripts and configurations for deploying and managing AI services, including model servers, content generation tools, and supporting infrastructure. The provided `docker-compose.ai.yml` file is used to orchestrate these services using Docker Compose.

## Services
The `docker-compose.ai.yml` file defines the following services:

1. **PyTorch Model Server**
   - Hosts AI models for inference.
   - Utilizes NVIDIA GPUs for acceleration.
   - Accessible on ports `8080` and `8081`.

2. **Stable Diffusion**
   - A content generation tool for creating images.
   - Requires NVIDIA GPUs.

3. **Redis**
   - A caching layer for fast data access.

4. **MongoDB**
   - A database for storing content and metadata.

5. **RabbitMQ**
   - A message queue for asynchronous communication between services.

## Prerequisites
- Docker and Docker Compose installed on your system.
- NVIDIA drivers and `nvidia-docker` runtime for GPU-based services.

## Deployment Instructions

1. Clone the repository:
   ```bash
   git clone <repository-url>
   cd dev-stack
   ```

2. Start the services:
   ```bash
   docker-compose -f docker-compose.ai.yml up -d
   ```

3. Verify the services are running:
   ```bash
   docker ps
   ```

## Scripts for Deployment

### `deploy.sh`
This script automates the deployment of the stack. Run it as follows:
```bash
./deploy.sh
```

### `manage-gpu.sh`
This script helps manage GPU resources for the services. Run it as follows:
```bash
./manage-gpu.sh
```

### `manage-gpu-spot.sh`
This script is used for managing spot instances with GPU resources. Run it as follows:
```bash
./manage-gpu-spot.sh
```

## Notes
- Update the environment variables in the `docker-compose.ai.yml` file as needed, such as `MONGO_PASSWORD` and `RABBITMQ_PASSWORD`.
- Ensure the required volumes (`model-store`, `sd-models`, etc.) are properly set up before starting the services.

## Troubleshooting
- Check the logs of a specific service:
  ```bash
  docker logs <container-name>
  ```
- Restart a specific service:
  ```bash
  docker-compose -f docker-compose.ai.yml restart <service-name>
  ```

## License
This project is licensed under the MIT License.
