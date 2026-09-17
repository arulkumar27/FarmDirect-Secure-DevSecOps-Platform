#!/bin/bash
set -e

IMAGE_TAG="${1:?Usage: ./deploy.sh <image-tag>}"

AWS_REGION="${AWS_REGION:-ap-south-1}"
EKS_CLUSTER_NAME="${EKS_CLUSTER_NAME:-farmdirect-production}"
K8S_NAMESPACE="${K8S_NAMESPACE:-farmdirect}"

AWS_ACCOUNT_ID=$(aws sts get-caller-identity \
    --query Account \
    --output text)

ECR_REGISTRY="${AWS_ACCOUNT_ID}.dkr.ecr.${AWS_REGION}.amazonaws.com"

echo "=========================================="
echo "FarmDirect EKS Deployment"
echo "=========================================="

echo "Cluster: ${EKS_CLUSTER_NAME}"
echo "Namespace: ${K8S_NAMESPACE}"
echo "Image Tag: ${IMAGE_TAG}"

echo "Updating kubeconfig..."

aws eks update-kubeconfig \
    --region "${AWS_REGION}" \
    --name "${EKS_CLUSTER_NAME}"

echo "Applying Kubernetes manifests..."

kubectl apply -k kubernetes/base

echo "Updating backend..."

kubectl -n "${K8S_NAMESPACE}" set image \
    deployment/backend \
    backend="${ECR_REGISTRY}/farmdirect-backend:${IMAGE_TAG}"

echo "Updating frontend..."

kubectl -n "${K8S_NAMESPACE}" set image \
    deployment/frontend \
    frontend="${ECR_REGISTRY}/farmdirect-frontend:${IMAGE_TAG}"

echo "Waiting for backend rollout..."

kubectl -n "${K8S_NAMESPACE}" rollout status \
    deployment/backend \
    --timeout=300s

echo "Waiting for frontend rollout..."

kubectl -n "${K8S_NAMESPACE}" rollout status \
    deployment/frontend \
    --timeout=300s

echo "Deployment successful."