#!/bin/bash
set -e

echo "Running backend tests..."

cd app/backend

npm ci
npm test -- --passWithNoTests

echo "Tests completed successfully."