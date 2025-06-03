#!/bin/bash
set -e

echo "Starting GoQuorum 5-Node QBFT Network (Simple Mode - No Private Transactions)..."

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

# Create a simplified docker-compose file without Tessera
cat > docker-compose-simple.yaml << EOF
version: '3.6'

x-quorum-def:
  &quorum-def
  restart: "on-failure"
  image: quorumengineering/quorum:latest
  expose:
    - "21000"
    - "50400"
    - "8545"
    - "8546"
    - "8547"
  healthcheck:
    test: ["CMD", "wget", "--spider", "--proxy", "off", "http://localhost:8545"]
    interval: 3s
    timeout: 3s
    retries: 10
    start_period: 5s
  environment:
    - PRIVATE_CONFIG=ignore
  entrypoint:
    - /bin/sh
    - -c
    - |
      # Initialize genesis block if not already initialized
      if [ ! -d "/qdata/dd/geth/chaindata" ]; then
        echo "Initializing genesis block..."
        geth --datadir /qdata/dd init /qdata/dd/genesis.json
      fi
      
      echo "Starting Quorum without private transaction support..."
      PRIVATE_CONFIG=ignore geth --datadir /qdata/dd \
        --nodiscover \
        --allow-insecure-unlock \
        --verbosity 5 \
        --istanbul.blockperiod 5 \
        --syncmode full \
        --mine \
        --miner.threads 1 \
        --http \
        --http.corsdomain "*" \
        --http.vhosts "*" \
        --http.addr 0.0.0.0 \
        --http.port 8545 \
        --http.api admin,eth,debug,miner,net,txpool,personal,web3,istanbul,quorumPermission,quorumExtension \
        --port 21000 \
        --unlock 0 \
        --password /qdata/passwords.txt

services:
  node-0:
    << : *quorum-def
    hostname: node-0
    ports:
      - "22000:8545"
      - "21000:21000"
    volumes:
      - ./qdata/node-0:/qdata

  node-1:
    << : *quorum-def
    hostname: node-1
    ports:
      - "22001:8545"
      - "21001:21000"
    volumes:
      - ./qdata/node-1:/qdata

  node-2:
    << : *quorum-def
    hostname: node-2
    ports:
      - "22002:8545"
      - "21002:21000"
    volumes:
      - ./qdata/node-2:/qdata

  node-3:
    << : *quorum-def
    hostname: node-3
    ports:
      - "22003:8545"
      - "21003:21000"
    volumes:
      - ./qdata/node-3:/qdata

  node-4:
    << : *quorum-def
    hostname: node-4
    ports:
      - "22004:8545"
      - "21004:21000"
    volumes:
      - ./qdata/node-4:/qdata

  explorer:
    image: blockscout/blockscout:latest
    restart: unless-stopped
    ports:
      - "4000:4000"
    environment:
      ETHEREUM_JSONRPC_HTTP_URL: http://node-0:8545
      DATABASE_URL: postgres://postgres:password@postgres:5432/blockscout
      NETWORK: Quorum-QBFT
    depends_on:
      - postgres
      - node-0

  postgres:
    image: postgres:13
    restart: unless-stopped
    environment:
      POSTGRES_USER: postgres
      POSTGRES_PASSWORD: password
      POSTGRES_DB: blockscout
    volumes:
      - postgres-data:/var/lib/postgresql/data

volumes:
  postgres-data:
EOF

# Start the network with Docker Compose
echo "Starting Docker containers (simple mode)..."
if ! docker-compose -f docker-compose-simple.yaml up -d; then
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
    echo "Node $i is not running. Please check the logs with 'docker-compose -f docker-compose-simple.yaml logs node-$i'."
  else
    echo "Node $i is running."
  fi
done

echo "Checking explorer..."
if ! docker ps | grep -q "goquorum-qbft-network-explorer"; then
  echo "Explorer is not running. Please check the logs with 'docker-compose -f docker-compose-simple.yaml logs explorer'."
else
  echo "Explorer is running."
fi

echo "Network started successfully (simple mode - no private transactions)!"
echo ""
echo "Access the Geth console for node 0:"
echo "docker exec -it goquorum-qbft-network-node-0-1 geth attach /qdata/dd/geth.ipc"
echo ""
echo "Access the Explorer:"
echo "http://localhost:4000"
echo ""
echo "To stop the network:"
echo "docker-compose -f docker-compose-simple.yaml down"
