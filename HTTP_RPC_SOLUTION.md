# HTTP RPC Solution for GoQuorum QBFT Network

## Overview

This document explains how to use the HTTP RPC endpoint to interact with the GoQuorum QBFT network instead of the IPC socket. This approach is useful when the IPC socket is not accessible or when you encounter the error: `Fatal: Error starting protocol stack: listen unix /qdata/dd/geth.ipc: bind: operation not supported`.

## Solution

The solution involves using the HTTP RPC endpoint that is exposed by the GoQuorum nodes instead of the IPC socket. This approach has several advantages:

1. It avoids the IPC socket issues that can occur in certain Docker environments
2. It allows for remote connections to the nodes
3. It's more compatible with web applications and services

## Key Insights

The key to making this work is using the `docker-compose-simple.yaml` configuration, which:

1. Explicitly disables IPC with the `--ipcdisable` flag
2. Is configured specifically for HTTP RPC access
3. Uses a simpler network setup that avoids the IPC socket issues

## Implementation

We've created the following files to implement this solution:

1. `deploy-fiatloan-http-simple.js` - A JavaScript file that uses web3.js to deploy the FiatLoanMatcher contract via HTTP RPC
2. `start-and-deploy-fiatloan-http.sh` - A shell script that starts the network and deploys the contract using the HTTP RPC endpoint

### HTTP RPC Endpoint

The HTTP RPC endpoint for each node is exposed on the following ports:

- Node 0: http://localhost:22000
- Node 1: http://localhost:22001
- Node 2: http://localhost:22002
- Node 3: http://localhost:22003
- Node 4: http://localhost:22004

## Usage

### Starting the Network and Deploying the Contract

To start the network and deploy the FiatLoanMatcher contract using the HTTP RPC endpoint, run:

```bash
./start-and-deploy-fiatloan-http.sh
```

This script will:
1. Start the GoQuorum QBFT network using the `docker-compose-simple.yaml` configuration
2. Wait for the network to initialize (30 seconds)
3. Check if the HTTP RPC endpoint is accessible
4. Install the required Node.js packages
5. Deploy the FiatLoanMatcher contract using the HTTP RPC endpoint

### Interacting with the Contract

After deployment, you can interact with the contract using the HTTP RPC endpoint. Here's an example of how to do this using web3.js:

```javascript
const Web3 = require('web3');
const web3 = new Web3('http://localhost:22000');

// Contract ABI and address (replace with your actual contract address)
const contractABI = [...]; // The ABI from deploy-fiatloan-http-simple.js
const contractAddress = '0x...'; // The address returned by the deployment script

// Create contract instance
const contract = new web3.eth.Contract(contractABI, contractAddress);

// Get accounts
const accounts = await web3.eth.getAccounts();
const accountAddress = accounts[0];

// Call contract methods
const loanCounter = await contract.methods.loanCounter().call();
console.log(`Current loan counter: ${loanCounter}`);

// Send transactions
const requestLoanTx = await contract.methods.requestLoan(
  "USD", 
  1000 * 100, // $1000 in cents
  50 * 100,   // $50 interest in cents
  30 * 24 * 60 * 60 // 30 days in seconds
).send({ from: accountAddress });

console.log(`Loan requested with ID: ${requestLoanTx.events.LoanRequested.returnValues.loanId}`);
```

## Troubleshooting

### Connection Issues

If you're having trouble connecting to the HTTP RPC endpoint, check that:

1. The network is running (`docker ps` should show the containers running)
2. The ports are correctly exposed (check the `docker-compose-simple.yaml` file)
3. You're using the correct URL (http://localhost:22000 for Node 0)
4. Make sure you're using the `docker-compose-simple.yaml` file, not the regular `docker-compose.yaml` file

### Transaction Issues

If your transactions are failing, check that:

1. The account you're using has enough ETH (you can check with `web3.eth.getBalance(accountAddress)`)
2. The account is unlocked (you can unlock it with `web3.eth.personal.unlockAccount(accountAddress, password, duration)`)
3. You're using the correct contract address and ABI

## Conclusion

Using the HTTP RPC endpoint with the `docker-compose-simple.yaml` configuration is a reliable alternative to the IPC socket for interacting with the GoQuorum QBFT network. The key difference is that this configuration explicitly disables IPC with the `--ipcdisable` flag and is configured specifically for HTTP RPC access. This approach provides more flexibility and avoids the issues that can occur with IPC sockets in Docker environments.
