#!/bin/bash
# start-and-deploy-fiatloan-http.sh - Start the network and deploy the FiatLoanMatcher contract using HTTP RPC

# Set the script to exit immediately if any command fails
set -e

echo "Starting GoQuorum QBFT network..."
docker-compose -f docker-compose-simple.yaml down
docker-compose -f docker-compose-simple.yaml up -d

echo "Waiting for the network to initialize (30 seconds)..."
sleep 30

echo "Checking if the network is up..."
curl -s -X POST -H "Content-Type: application/json" \
  --data '{"jsonrpc":"2.0","method":"eth_blockNumber","params":[],"id":1}' \
  http://localhost:22000

echo "Installing required Node.js packages..."
npm install web3

echo -e "\nDeploying FiatLoanMatcher contract using HTTP RPC..."
node deploy-fiatloan-http-simple.js

echo "Deployment completed successfully!"
echo "You can now interact with the contract using the HTTP RPC endpoint at http://localhost:22000"
