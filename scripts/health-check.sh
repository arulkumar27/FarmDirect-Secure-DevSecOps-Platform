#!/bin/bash
set -e

K8S_NAMESPACE="${K8S_NAMESPACE:-farmdirect}"

echo "=========================================="
echo "FarmDirect Health Check"
echo "=========================================="

echo ""
echo "Pods:"
kubectl get pods -n "${K8S_NAMESPACE}"

echo ""
echo "Services:"
kubectl get svc -n "${K8S_NAMESPACE}"

echo ""
echo "Deployments:"
kubectl get deployments -n "${K8S_NAMESPACE}"

echo ""
echo "Backend rollout:"
kubectl rollout status \
    deployment/backend \
    -n "${K8S_NAMESPACE}" \
    --timeout=120s

echo ""
echo "Frontend rollout:"
kubectl rollout status \
    deployment/frontend \
    -n "${K8S_NAMESPACE}" \
    --timeout=120s

echo ""
echo "Health check completed."