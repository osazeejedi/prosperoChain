#!/bin/bash
set -e

# Configuration
REMOTE_IP="167.99.87.113"
REMOTE_USER="root"
REMOTE_PASSWORD="JdW^FTy8D/b/PYz"
RPC_URL="http://${REMOTE_IP}:22000"

echo "Verifying GoQuorum QBFT Network deployment on ${REMOTE_IP}..."

# Check if sshpass is installed
if ! command -v sshpass &> /dev/null; then
  echo "sshpass not found. Please install it to continue."
  echo "On macOS: brew install hudochenkov/sshpass/sshpass"
  echo "On Ubuntu: apt-get install sshpass"
  exit 1
fi

# Connect to remote server and check Docker containers
echo "Checking Docker containers..."
sshpass -p "$REMOTE_PASSWORD" ssh -o StrictHostKeyChecking=no $REMOTE_USER@$REMOTE_IP << EOF
  echo "Running containers:"
  docker ps
  
  echo -e "\nContainer resource usage:"
  docker stats --no-stream
  
  echo -e "\nDisk space usage:"
  df -h
  
  echo -e "\nDocker disk usage:"
  docker system df
  
  echo -e "\nChecking GoQuorum logs (last 10 lines):"
  docker logs \$(docker ps | grep node-0 | awk '{print \$1}') --tail 10 2>/dev/null || echo "No node-0 container found"
EOF

# Check if RPC endpoint is accessible
echo -e "\nChecking RPC endpoint..."
if command -v curl &> /dev/null; then
  RESPONSE=$(curl -s -X POST -H "Content-Type: application/json" --data '{"jsonrpc":"2.0","method":"eth_blockNumber","params":[],"id":1}' $RPC_URL)
  if [ $? -eq 0 ] && [ ! -z "$RESPONSE" ]; then
    echo "RPC endpoint is accessible."
    echo "Response: $RESPONSE"
    
    # Check if we can get the node info
    NODE_INFO=$(curl -s -X POST -H "Content-Type: application/json" --data '{"jsonrpc":"2.0","method":"admin_nodeInfo","params":[],"id":1}' $RPC_URL)
    echo -e "\nNode info: $NODE_INFO"
    
    # Check if we can get accounts
    ACCOUNTS=$(curl -s -X POST -H "Content-Type: application/json" --data '{"jsonrpc":"2.0","method":"eth_accounts","params":[],"id":1}' $RPC_URL)
    echo -e "\nAccounts: $ACCOUNTS"
  else
    echo "RPC endpoint is not accessible."
    echo "Response: $RESPONSE"
  fi
else
  echo "curl not found. Please install it to check the RPC endpoint."
fi

echo -e "\nVerification completed."
