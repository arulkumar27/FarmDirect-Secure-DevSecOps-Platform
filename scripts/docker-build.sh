#!/bin/bash
set -e

IMAGE_TAG="${1:-latest}"

echo "Building FarmDirect Docker images..."
echo "Tag: ${IMAGE_TAG}"

docker build \
    -f docker/backend/Dockerfile \
    -t farmdirect-backend:${IMAGE_TAG} \
    .

docker build \
    -f docker/frontend/Dockerfile \
    -t farmdirect-frontend:${IMAGE_TAG} \
    .

echo "Docker images built successfully."

docker images | grep farmdirect