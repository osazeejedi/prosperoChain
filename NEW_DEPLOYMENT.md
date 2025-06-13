# New GoQuorum QBFT Network Deployment

This document provides instructions for deploying the GoQuorum QBFT network to the new droplet with IP address 167.99.207.201.

## Overview

Due to issues with the previous deployment, we've created a new set of scripts to deploy a lightweight version of the GoQuorum network to a new droplet. The lightweight version excludes the Tessera private transaction manager and the Blockscout explorer, significantly reducing resource requirements.

## Deployment Scripts

The following scripts have been created for the new deployment:

1. **deploy-to-new-droplet.sh**: Main deployment script that sets up the lightweight GoQuorum network on the new droplet.
2. **test-new-rpc-endpoint.sh**: Tests the RPC endpoint on the new droplet.
3. **verify-new-deployment.sh**: Verifies the deployment status on the new droplet.
4. **deploy-new-remote-http.js**: Deploys a SimpleStorage contract to the new network.

## Deployment Steps

### 1. Deploy the Network

```bash
# Make the script executable (if not already)
chmod +x deploy-to-new-droplet.sh

# Run the deployment script
./deploy-to-new-droplet.sh
```

The script will:
- Package all necessary files
- Transfer them to the new droplet
- Set up the GoQuorum network
- Start the network
- Verify the deployment

### 2. Verify the Deployment

After the deployment script completes, you can verify the deployment using:

```bash
# Make the script executable (if not already)
chmod +x verify-new-deployment.sh

# Run the verification script
./verify-new-deployment.sh
```

This script will:
- Check if Docker containers are running on the remote server
- Display resource usage and disk space information
- Test if the RPC endpoint is accessible
- Show the latest logs from the node-0 container

### 3. Test the RPC Endpoint

You can test if the RPC endpoint is accessible and functioning properly:

```bash
# Make the script executable (if not already)
chmod +x test-new-rpc-endpoint.sh

# Run the RPC testing script
./test-new-rpc-endpoint.sh
```

This script will:
- Test basic connectivity to the RPC endpoint
- Check if basic JSON-RPC methods are working
- Display the responses from the RPC endpoint

### 4. Deploy a Test Contract

To deploy a test contract to the new network:

```bash
# Install required Node.js packages (if not already installed)
npm install web3 solc

# Deploy the SimpleStorage contract
node deploy-new-remote-http.js
```

This script will:
- Connect to the GoQuorum node on the new droplet
- Compile the SimpleStorage contract
- Deploy the contract
- Test the contract functionality

## Troubleshooting

### Connection Issues

If you cannot connect to the RPC endpoint:

1. Run the verification script to check the status:
   ```bash
   ./verify-new-deployment.sh
   ```

2. Check if Docker containers are running on the remote server:
   ```bash
   ssh root@167.99.207.201 "cd /opt/prosperoNetwork/goquorum-qbft-network && docker-compose ps"
   ```

3. Verify that port 22000 is open in the firewall:
   ```bash
   ssh root@167.99.207.201 "ufw status"
   ```

4. Check the Docker logs for any errors:
   ```bash
   ssh root@167.99.207.201 "cd /opt/prosperoNetwork/goquorum-qbft-network && docker-compose logs node-0"
   ```

### Disk Space Issues

If you encounter disk space issues:

1. Check disk space usage:
   ```bash
   ssh root@167.99.207.201 "df -h"
   ```

2. Clean up Docker resources:
   ```bash
   ssh root@167.99.207.201 "docker system prune -a"
   ```

### Stopping the Network

To stop the network on the remote server:

```bash
ssh root@167.99.207.201
cd /opt/prosperoNetwork/goquorum-qbft-network
docker-compose down
```

## Differences from Previous Deployment

The new deployment differs from the previous one in the following ways:

1. **No Tessera Private Transaction Manager**: The lightweight version runs with `PRIVATE_CONFIG=ignore`, which disables private transaction support.

2. **No Blockscout Explorer**: The full deployment included a Blockscout blockchain explorer with a PostgreSQL database, which has been removed in the lightweight version.

3. **Reduced Verbosity**: The logging level is reduced from verbosity 5 to verbosity 3, reducing the amount of log data generated.

4. **Simplified Configuration**: The entrypoint script is simplified, removing the Tessera waiting logic.

5. **Same Core Functionality**: Still maintains the 5-node QBFT consensus network and supports public transactions and smart contracts.

## Security Considerations

The current deployment exposes the RPC endpoint publicly. In a production environment, consider:

1. Implementing firewall rules to restrict access
2. Setting up HTTPS for the RPC endpoint
3. Implementing authentication for the RPC endpoint
4. Regular monitoring and updates
