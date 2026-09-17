#!/bin/bash
set -e

K8S_NAMESPACE="${K8S_NAMESPACE:-farmdirect}"

echo "FarmDirect cleanup"

read -p "Delete FarmDirect Kubernetes resources? (yes/no): " CONFIRM

if [ "${CONFIRM}" != "yes" ]; then
    echo "Cleanup cancelled."
    exit 0
fi

kubectl delete \
    -k kubernetes/base \
    --ignore-not-found

echo "Kubernetes resources deleted."