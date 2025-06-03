#!/bin/bash

# start-and-deploy-http.sh - Start the GoQuorum network and deploy the SimpleStorage contract

echo "Starting GoQuorum QBFT network..."
docker-compose -f docker-compose-simple.yaml down
docker-compose -f docker-compose-simple.yaml up -d

echo "Waiting for the network to initialize (30 seconds)..."
sleep 30

echo "Checking if the network is up..."
curl -s -X POST -H "Content-Type: application/json" \
  --data '{"jsonrpc":"2.0","method":"eth_blockNumber","params":[],"id":1}' \
  http://localhost:22000

echo -e "\nDeploying SimpleStorage contract..."
node deploy-http.js

echo "Deployment complete!"
