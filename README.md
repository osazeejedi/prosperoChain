# GoQuorum 5-Node QBFT Network

This project sets up a production-grade 5-node GoQuorum network using QBFT consensus with Docker Compose.

## Overview

This implementation:
- Uses QBFT (Quorum Byzantine Fault Tolerance) consensus
- Includes 5 GoQuorum nodes and 5 Tessera nodes for private transactions
- Provides a Blockscout explorer for transaction visibility
- Uses Docker Compose for easy deployment and management

## Prerequisites

* Docker & Docker Compose
* Git

## Setup and Running

### 1. Make Scripts Executable

```bash
chmod +x generate-keys.sh generate-configs.sh start-network.sh
```

### 2. Start the Network

#### Full Network (with Private Transactions)

```bash
chmod +x start-network.sh
./start-network.sh
```

This script will:
1. Generate keys for the 5 nodes
2. Generate configurations for the nodes
3. Start the Docker containers for the network with Tessera for private transactions

#### Simple Network (without Private Transactions)

If you're having issues with Tessera or don't need private transactions, you can use the simplified version:

```bash
chmod +x start-network-simple.sh
./start-network-simple.sh
```

This script will:
1. Generate keys for the 5 nodes
2. Generate configurations for the nodes
3. Start the Docker containers for the network without Tessera (using PRIVATE_CONFIG=ignore)

### 3. Access the Network

#### Geth Console

To access the Geth console for node 0:

```bash
docker exec -it goquorum-qbft-network-node-0-1 geth attach /qdata/dd/geth.ipc
```

#### Explorer

Access the Blockscout explorer at:

```
http://localhost:4000
```

### 4. Deploy a Smart Contract

#### Option 1: Deploy SimpleStorage Contract (Recommended)

Copy the deploy-simple-storage.js file to node-0:

```bash
docker cp deploy-simple-storage.js goquorum-qbft-network-node-0-1:/qdata/
```

Deploy the contract:

```bash
docker exec -it goquorum-qbft-network-node-0-1 geth --exec "loadScript('/qdata/deploy-simple-storage.js')" attach /qdata/dd/geth.ipc
```

This will:
1. Deploy a SimpleStorage contract that can store and retrieve a numeric value
2. Wait for the contract deployment transaction to be mined
3. Create a contract instance at the deployed address
4. Test the contract by storing and retrieving a value (42)

The script includes:
- Comprehensive environment information for debugging
- Proper transaction handling and waiting for transactions to be mined
- Address validation and contract code verification
- Multiple approaches to interact with the contract (both high-level and low-level)
- Robust error handling with fallback methods

You should see output similar to:
```
=== Environment Information ===
Node info: enode://...
Protocol version: 65
Network ID: 1337
Block number: 42
Using account: 0x...
Account balance: 100 ETH
==============================
Unlocking account...
Account unlocked: true
Creating contract object...
Deploying the SimpleStorage contract...
Waiting for the contract to be mined (txHash: 0x...)...
Waiting for transaction to be mined...
Contract mined! Address: 0x...
Validating contract address: 0x...
Contract code at address: Code exists (length: 300)
Creating contract instance...
Checking contract methods...
Contract methods: retrieve, store
Testing the contract...
Initial value: 0
Storing new value (42)...
Store transaction hash: 0x...
Waiting for store transaction to be mined...
New value: 42
Contract deployment and testing completed!
Contract address for future reference: 0x...
```

If you encounter any issues with the contract deployment, the script will provide detailed error information and attempt alternative approaches to interact with the contract.

#### Option 2: Deploy HelloWorld Contract

Copy the deploy-contract.js file to node-0:

```bash
docker cp deploy-contract.js goquorum-qbft-network-node-0-1:/qdata/
```

Deploy the contract:

```bash
docker exec -it goquorum-qbft-network-node-0-1 geth --exec "loadScript('/qdata/deploy-contract.js')" attach /qdata/dd/geth.ipc
```

### 5. Stop the Network

```bash
docker-compose down
```

## Working with Accounts

### List Accounts

```javascript
eth.accounts
```

### Check Balance

```javascript
web3.fromWei(eth.getBalance(eth.accounts[0]), "ether")
```

### Send Transaction

```javascript
eth.sendTransaction({
  from: eth.accounts[0],
  to: eth.accounts[1],
  value: web3.toWei(1, "ether")
})
```

## Troubleshooting

### Docker Issues

If you encounter Docker-related issues:

```bash
# Check Docker logs for a specific service
docker-compose logs node-0
docker-compose logs tessera-0
docker-compose logs explorer

# Check container status
docker ps | grep goquorum-qbft-network

# Restart a specific service
docker-compose restart node-0

# Rebuild and restart all services
docker-compose down
docker-compose up -d
```

### Network Initialization Issues

If the network fails to initialize properly:

1. Check that the quorum-examples repository is properly cloned
2. Ensure Docker and Docker Compose are installed and running
3. Check the logs for specific error messages:

```bash
# Check Tessera logs
docker logs goquorum-qbft-network-tessera-0-1

# Check Quorum node logs
docker logs goquorum-qbft-network-node-0-1
```

4. If Tessera containers are failing, check the Tessera configuration:

```bash
cat qdata/node-0/tessera-config.json
```

5. Try cleaning up and starting fresh:

```bash
docker-compose down -v
rm -rf qdata
./start-network.sh
```

6. If you're still having issues, try running with a simpler configuration without private transactions:

```bash
# Modify docker-compose.yaml to remove Tessera dependency
# Change the Quorum node entrypoint to not wait for tm.ipc
# Set PRIVATE_CONFIG=ignore
```

## Repository Structure

```
goquorum-qbft-network/
├── docker-compose.yaml         # Docker Compose configuration
├── docker-compose-simple.yaml  # Simplified Docker Compose configuration (no Tessera)
├── generate-keys.sh            # Script to generate node keys
├── generate-configs.sh         # Script to generate node configurations
├── start-network.sh            # Script to start the network
├── start-network-simple.sh     # Script to start the simplified network
├── HelloWorld.sol              # Sample HelloWorld contract
├── SimpleStorage.sol           # Sample SimpleStorage contract
├── deploy-contract.js          # Script to deploy the HelloWorld contract
├── deploy-simple-storage.js    # Script to deploy the SimpleStorage contract
└── qdata/                      # Node data directories
    ├── node-0/                 # Data for node 0
    ├── node-1/                 # Data for node 1
    ├── node-2/                 # Data for node 2
    ├── node-3/                 # Data for node 3
    └── node-4/                 # Data for node 4
```

## Notes for Production

* Secure node keys using HashiCorp Vault or cloud KMS
* Protect RPC endpoints
* Use Docker secrets or `.env` for passwords
* Monitor using Prometheus + Grafana
* Include firewall and node-level security measures
