#!/bin/bash
set -e

IMAGE_TAG="${1:-latest}"
AWS_REGION="${AWS_REGION:-ap-south-1}"

AWS_ACCOUNT_ID=$(aws sts get-caller-identity \
    --query Account \
    --output text)

ECR_REGISTRY="${AWS_ACCOUNT_ID}.dkr.ecr.${AWS_REGION}.amazonaws.com"

echo "Pushing FarmDirect images..."

docker tag \
    farmdirect-backend:${IMAGE_TAG} \
    ${ECR_REGISTRY}/farmdirect-backend:${IMAGE_TAG}

docker tag \
    farmdirect-frontend:${IMAGE_TAG} \
    ${ECR_REGISTRY}/farmdirect-frontend:${IMAGE_TAG}

docker push \
    ${ECR_REGISTRY}/farmdirect-backend:${IMAGE_TAG}

docker push \
    ${ECR_REGISTRY}/farmdirect-frontend:${IMAGE_TAG}

echo "Images pushed successfully."