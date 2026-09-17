#!/bin/bash
set -e

K8S_NAMESPACE="${K8S_NAMESPACE:-farmdirect}"

echo "Rolling back FarmDirect deployments..."

kubectl rollout undo \
    deployment/backend \
    -n "${K8S_NAMESPACE}"

kubectl rollout undo \
    deployment/frontend \
    -n "${K8S_NAMESPACE}"

echo "Waiting for rollback..."

kubectl rollout status \
    deployment/backend \
    -n "${K8S_NAMESPACE}" \
    --timeout=300s

kubectl rollout status \
    deployment/frontend \
    -n "${K8S_NAMESPACE}" \
    --timeout=300s

echo "Rollback completed."