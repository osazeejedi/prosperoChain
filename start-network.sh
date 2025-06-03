#!/bin/bash
set -e

echo "Starting GoQuorum 5-Node QBFT Network..."

# Check if Docker is running
if ! docker info > /dev/null 2>&1; then
  echo "Docker is not running. Please start Docker and try again."
  exit 1
fi

# Check if keys and configs have been generated
if [ ! -d "qdata/node-0/dd/geth" ]; then
  echo "Node configurations not found. Running setup scripts..."
  
  # Make scripts executable
  chmod +x generate-keys.sh generate-configs.sh
  
    # Generate keys and configurations
  if ! ./generate-keys.sh; then
    echo "Error generating keys. Please check the error message above."
    exit 1
  fi
  
  if ! ./generate-configs.sh; then
    echo "Error generating configurations. Please check the error message above."
    exit 1
  fi
fi

# Start the network with Docker Compose
echo "Starting Docker containers..."
if ! docker-compose up -d; then
  echo "Error starting Docker containers. Please check the error message above."
  exit 1
fi

echo "Waiting for the network to start..."
sleep 10

# Check if nodes are running
for i in {0..4}
do
  echo "Checking node-$i..."
  if ! docker ps | grep -q "goquorum-qbft-network-node-$i"; then
    echo "Node $i is not running. Please check the logs with 'docker-compose logs node-$i'."
  else
    echo "Node $i is running."
  fi
done

echo "Checking explorer..."
if ! docker ps | grep -q "goquorum-qbft-network-explorer"; then
  echo "Explorer is not running. Please check the logs with 'docker-compose logs explorer'."
else
  echo "Explorer is running."
fi

echo "Network started successfully!"
echo ""
echo "Access the Geth console for node 0:"
echo "docker exec -it goquorum-qbft-network-node-0-1 geth attach /qdata/dd/geth.ipc"
echo ""
echo "Access the Explorer:"
echo "http://localhost:4000"
echo ""
echo "To stop the network:"
echo "docker-compose down"
