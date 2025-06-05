# Remote Deployment of GoQuorum QBFT Network

This document provides instructions for deploying the GoQuorum QBFT network to a remote Ubuntu server with Docker installed.

## Prerequisites

- A remote Ubuntu server with Docker installed
- SSH access to the remote server
- The `sshpass` utility installed on your local machine (for password-based authentication)

## Deployment Steps

### 1. Prepare for Deployment

The deployment process uses the `deploy-to-remote.sh` script, which:

1. Creates a tar archive of the necessary files
2. Transfers the archive to the remote server
3. Extracts the archive on the remote server
4. Sets up and starts the network on the remote server

### 2. Run the Deployment Script

```bash
# Make the script executable (if not already)
chmod +x deploy-to-remote.sh

# Run the deployment script
./deploy-to-remote.sh
```

The script will:
- Package all necessary files
- Transfer them to the remote server
- Set up the GoQuorum network
- Start the network

### 3. Verify the Deployment

After the script completes, you should see a message indicating that the deployment was successful. The RPC endpoint will be available at:

```
http://167.99.87.113:22000
```

You can verify the deployment using the verification script:

```bash
# Make the script executable (if not already)
chmod +x verify-remote-deployment.sh

# Run the verification script
./verify-remote-deployment.sh
```

This script will:
- Check if Docker containers are running on the remote server
- Display resource usage and disk space information
- Test if the RPC endpoint is accessible
- Show the latest logs from the node-0 container

Alternatively, you can manually verify by:

1. SSH into the remote server:
   ```bash
   ssh root@167.99.87.113
   ```

2. Check the running Docker containers:
   ```bash
   cd /opt/prosperoNetwork/goquorum-qbft-network
   docker-compose ps
   ```

3. View the logs:
   ```bash
   docker-compose logs -f
   ```

### 4. Troubleshooting Disk Space Issues

If you encounter disk space issues during deployment (e.g., "no space left on device" errors), you can use the cleanup script:

```bash
# Make the script executable (if not already)
chmod +x cleanup-remote-server.sh

# Run the cleanup script
./cleanup-remote-server.sh
```

This script will:
- Stop non-essential Docker containers
- Remove unused Docker images, containers, and volumes
- Clean up system logs and temporary files
- Display disk space before and after cleanup

### 5. Lightweight Deployment Option

If disk space issues persist after cleanup, you can use the lightweight deployment option:

```bash
# Make the script executable (if not already)
chmod +x deploy-lightweight-network.sh

# Run the lightweight deployment script
./deploy-lightweight-network.sh
```

This script deploys a minimal version of the GoQuorum network without Tessera private transaction manager and the Blockscout explorer, significantly reducing the disk space requirements.

## Interacting with the Remote Network

### Using the HTTP RPC Endpoint

You can interact with the network using the HTTP RPC endpoint at `http://167.99.87.113:22000`. This endpoint can be used with web3.js, ethers.js, or any other Ethereum-compatible library.

### Deploying Contracts

Two scripts are provided to deploy contracts to the remote network:

1. **SimpleStorage Contract**:
   ```bash
   node deploy-remote-http.js
   ```

2. **FiatLoanMatcher Contract**:
   ```bash
   node deploy-fiatloan-remote-http.js
   ```

These scripts connect to the remote RPC endpoint, deploy the respective contracts, and verify their functionality.

### Verifying Contract Deployment

After deploying a contract, you can verify it's working by:

1. Using the verification script to check if the RPC endpoint is accessible:
   ```bash
   ./verify-remote-deployment.sh
   ```

2. Checking the transaction receipt and contract address in the deployment script output

3. Interacting with the deployed contract using the provided contract address

### Customizing the Deployment

If you need to modify the deployment configuration:

1. Edit `docker-compose-remote.yaml` to change Docker settings
2. Edit `deploy-to-remote.sh` to change deployment parameters
3. Edit the deployment scripts to change contract deployment parameters

## Troubleshooting

### Connection Issues

If you cannot connect to the RPC endpoint:

1. Run the verification script to check the status:
   ```bash
   ./verify-remote-deployment.sh
   ```

2. If issues are detected, try cleaning up disk space:
   ```bash
   ./cleanup-remote-server.sh
   ```

3. If problems persist, try the lightweight deployment:
   ```bash
   ./deploy-lightweight-network.sh
   ```

4. Check if Docker containers are running on the remote server:
   ```bash
   ssh root@167.99.87.113 "cd /opt/prosperoNetwork/goquorum-qbft-network && docker-compose ps"
   ```

5. Verify that port 22000 is open in the firewall:
   ```bash
   ssh root@167.99.87.113 "ufw status"
   ```

6. Check the Docker logs for any errors:
   ```bash
   ssh root@167.99.87.113 "cd /opt/prosperoNetwork/goquorum-qbft-network && docker-compose logs node-0"
   ```

### Disk Space Issues

If you encounter "no space left on device" errors:

1. Check disk space usage:
   ```bash
   ssh root@167.99.87.113 "df -h"
   ```

2. Run the cleanup script:
   ```bash
   ./cleanup-remote-server.sh
   ```

3. If needed, switch to the lightweight deployment:
   ```bash
   ./deploy-lightweight-network.sh
   ```

### Contract Deployment Issues

If contract deployment fails:

1. Ensure the network is running properly (use verify-remote-deployment.sh)
2. Check that the account has sufficient funds
3. Verify that the account is unlocked
4. Check for JavaScript errors in the deployment script

### Stopping the Network

To stop the network on the remote server:

```bash
ssh root@167.99.87.113
cd /opt/prosperoNetwork/goquorum-qbft-network
docker-compose down
```

## Security Considerations

The current deployment exposes the RPC endpoint publicly. In a production environment, consider:

1. Implementing firewall rules to restrict access
2. Setting up HTTPS for the RPC endpoint
3. Implementing authentication for the RPC endpoint
4. Regular monitoring and updates

## Additional Resources

- [GoQuorum Documentation](https://docs.goquorum.consensys.net/)
- [Web3.js Documentation](https://web3js.readthedocs.io/)
- [Docker Documentation](https://docs.docker.com/)
