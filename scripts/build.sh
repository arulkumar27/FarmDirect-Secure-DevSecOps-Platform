#!/bin/bash
set -e

echo "Building FarmDirect application..."

cd app/backend
npm ci
npm test -- --passWithNoTests

cd ../frontend
npm ci
npm run build

echo "Application build completed successfully."