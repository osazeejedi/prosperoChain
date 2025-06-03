# GoQuorum QBFT Network HTTP RPC Solution

## Problem

The original network configuration was encountering an error when trying to start the nodes:

```
Fatal: Error starting protocol stack: listen unix /qdata/dd/geth.ipc: bind: operation not supported
```

This error occurs because the Docker container was unable to create the IPC (Inter-Process Communication) socket file. This is a common issue when running Ethereum nodes in Docker containers, especially on certain operating systems or Docker configurations.

## Solution

The solution was to disable the IPC endpoint completely and use only the HTTP RPC endpoint for communication with the nodes. This was achieved by adding the `--ipcdisable` flag to the geth command in the Docker Compose configuration.

### Changes Made

1. Modified `docker-compose-simple.yaml` to add the `--ipcdisable` flag to the geth command:

```yaml
PRIVATE_CONFIG=ignore geth --datadir /qdata/dd         --nodiscover         --allow-insecure-unlock         --verbosity 5         --istanbul.blockperiod 5         --syncmode full         --mine         --miner.threads 1         --ipcdisable         --http         --http.corsdomain "*"         --http.vhosts "*"         --http.addr 0.0.0.0         --http.port 8545         --http.api admin,eth,debug,miner,net,txpool,personal,web3,istanbul,quorumPermission,quorumExtension         --port 21000         --unlock 0         --password /qdata/passwords.txt
```

2. Created a deployment script (`deploy-http.js`) that uses the HTTP RPC endpoint instead of IPC:

```javascript
// Configuration
const RPC_URL = 'http://localhost:22000'; // Node 0 HTTP RPC endpoint
const web3 = new Web3(RPC_URL);
```

### Verification

The solution was verified by:

1. Starting the network with the updated configuration:
   ```
   docker-compose -f docker-compose-simple.yaml up -d
   ```

2. Checking that the nodes are running properly:
   ```
   docker-compose -f docker-compose-simple.yaml ps
   ```

3. Testing the HTTP RPC endpoint with a simple query:
   ```
   curl -X POST -H "Content-Type: application/json" --data '{"jsonrpc":"2.0","method":"eth_blockNumber","params":[],"id":1}' http://localhost:22000
   ```

4. Deploying a SimpleStorage contract using the HTTP RPC endpoint:
   ```
   node deploy-http.js
   ```

5. Verifying the deployed contract:
   ```
   node check-contract.js <contract-address>
   ```

### Results

- All nodes are now running properly with the HTTP RPC endpoint enabled.
- The SimpleStorage contract was successfully deployed and tested.
- The contract is accessible and functional through the HTTP RPC endpoint.

## Conclusion

By disabling the IPC endpoint and using only the HTTP RPC endpoint, we were able to resolve the issue with the GoQuorum nodes in Docker. This approach allows for successful deployment and interaction with smart contracts on the network.

## Contract Information

- Contract Address: 0x9d13C6D3aFE1721BEef56B55D303B09E021E27ab
- Contract Type: SimpleStorage
- Stored Value: 42

## Additional Notes

- The HTTP RPC endpoint is exposed on port 22000 for node-0.
- The account used for deployment is the first account on the node (0xed9d02e382b34818e88B88a309c7fe71E65f419d).
- The network ID is 1337.
