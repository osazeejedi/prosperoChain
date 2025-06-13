#!/bin/bash
set -e

# Configuration
NEW_IP="167.99.207.201"
REMOTE_USER="root"
REMOTE_PASSWORD="7cn@hv)yqkJ*j"

echo "Verifying GoQuorum QBFT Network deployment on $NEW_IP..."

# Check if sshpass is installed
if ! command -v sshpass &> /dev/null; then
  echo "sshpass not found. Please install it to continue."
  echo "On macOS: brew install hudochenkov/sshpass/sshpass"
  echo "On Ubuntu: apt-get install sshpass"
  exit 1
fi

# Execute commands on the remote server
echo "Checking deployment status on the remote server..."
sshpass -p "$REMOTE_PASSWORD" ssh -o StrictHostKeyChecking=no $REMOTE_USER@$NEW_IP << 'EOF'
  echo "Current directory: $(pwd)"
  
  # Check if the GoQuorum directory exists
  if [ -d "/opt/prosperoNetwork/goquorum-qbft-network" ]; then
    echo "GoQuorum directory exists."
  else
    echo "ERROR: GoQuorum directory not found!"
    exit 1
  fi
  
  # Navigate to the GoQuorum directory
  cd /opt/prosperoNetwork/goquorum-qbft-network
  
  # Check Docker containers
  echo -e "\nDocker containers:"
  docker ps
  
  # Check disk space
  echo -e "\nDisk space usage:"
  df -h
  
  # Check Docker disk usage
  echo -e "\nDocker disk usage:"
  docker system df
  
  # Check if nodes are running
  echo -e "\nChecking node containers:"
  for i in {0..4}
  do
    if docker ps | grep -q "node-$i"; then
      echo "Node $i is running."
    else
      echo "WARNING: Node $i is not running!"
    fi
  done
  
  # Check GoQuorum logs
  echo -e "\nChecking GoQuorum logs (last 10 lines):"
  docker logs $(docker ps | grep node-0 | awk '{print $1}') --tail 10 2>/dev/null || echo "No node-0 container found"
  
  # Check if RPC endpoint is accessible
  echo -e "\nChecking RPC endpoint..."
  curl -s -X POST -H "Content-Type: application/json" --data '{"jsonrpc":"2.0","method":"eth_blockNumber","params":[],"id":1}' http://localhost:22000
  echo ""
  
  # Check if we can get the node info
  echo -e "\nGetting node info:"
  curl -s -X POST -H "Content-Type: application/json" --data '{"jsonrpc":"2.0","method":"admin_nodeInfo","params":[],"id":1}' http://localhost:22000
  echo ""
  
  # Check if we can get accounts
  echo -e "\nGetting accounts:"
  curl -s -X POST -H "Content-Type: application/json" --data '{"jsonrpc":"2.0","method":"eth_accounts","params":[],"id":1}' http://localhost:22000
  echo ""
EOF

# Test RPC endpoint from local machine
echo -e "\nTesting RPC endpoint from local machine..."
./test-new-rpc-endpoint.sh

echo -e "\nVerification completed."
