#!/bin/bash
set -e

AWS_REGION="${AWS_REGION:-ap-south-1}"

AWS_ACCOUNT_ID=$(aws sts get-caller-identity \
    --query Account \
    --output text)

ECR_REGISTRY="${AWS_ACCOUNT_ID}.dkr.ecr.${AWS_REGION}.amazonaws.com"

echo "Logging into ECR: ${ECR_REGISTRY}"

aws ecr get-login-password \
    --region "${AWS_REGION}" |
docker login \
    --username AWS \
    --password-stdin "${ECR_REGISTRY}"

echo "ECR login successful."