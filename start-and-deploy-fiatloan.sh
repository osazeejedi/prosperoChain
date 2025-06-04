#!/bin/bash

# start-and-deploy-fiatloan.sh - Start the GoQuorum network and deploy the FiatLoanMatcher contract

echo "Starting GoQuorum QBFT network..."
docker-compose -f docker-compose-simple.yaml down
docker-compose -f docker-compose-simple.yaml up -d

echo "Waiting for the network to initialize (30 seconds)..."
sleep 30

echo "Checking if the network is up..."
curl -s -X POST -H "Content-Type: application/json" \
  --data '{"jsonrpc":"2.0","method":"eth_blockNumber","params":[],"id":1}' \
  http://localhost:22000

echo -e "\nDeploying FiatLoanMatcher contract..."
node deploy-fiatloan-http.js

echo "Deployment complete!"
echo "See FIATLOAN_INTEGRATION.md for integration details."
