// deploy-http.js - Deploy SimpleStorage contract using HTTP RPC
// This script uses web3.js to connect to the GoQuorum node via HTTP RPC
// Run with: node deploy-http.js

const Web3 = require('web3');
const fs = require('fs');
const path = require('path');

// Configuration
const RPC_URL = 'http://localhost:22000'; // Node 0 HTTP RPC endpoint
const ACCOUNT_ADDRESS = ''; // Will be populated from the node
const ACCOUNT_PASSWORD = ''; // Empty password as per your setup

// Contract data
const contractSource = fs.readFileSync(path.join(__dirname, 'SimpleStorage.sol'), 'utf8');
const contractABI = [
  {
    "inputs": [],
    "name": "retrieve",
    "outputs": [
      {
        "internalType": "uint256",
        "name": "",
        "type": "uint256"
      }
    ],
    "stateMutability": "view",
    "type": "function"
  },
  {
    "inputs": [
      {
        "internalType": "uint256",
        "name": "num",
        "type": "uint256"
      }
    ],
    "name": "store",
    "outputs": [],
    "stateMutability": "nonpayable",
    "type": "function"
  }
];

const contractBytecode = "0x608060405234801561001057600080fd5b50610150806100206000396000f3fe608060405234801561001057600080fd5b50600436106100365760003560e01c80632e64cec11461003b5780636057361d14610059575b600080fd5b610043610075565b60405161005091906100a1565b60405180910390f35b610073600480360381019061006e91906100ed565b61007e565b005b60008054905090565b8060008190555050565b6000819050919050565b61009b81610088565b82525050565b60006020820190506100b66000830184610092565b92915050565b600080fd5b6100ca81610088565b81146100d557600080fd5b50565b6000813590506100e7816100c1565b92915050565b600060208284031215610103576101026100bc565b5b6000610111848285016100d8565b9150509291505056fea2646970667358221220322c78243e61b783558509c9cc22cb8493dde6925aa5e89a08cdf6e22f279ef164736f6c63430008120033";

// Main function
async function main() {
  try {
    console.log(`Connecting to GoQuorum node at ${RPC_URL}...`);
    const web3 = new Web3(RPC_URL);
    
    // Check connection
    const isConnected = await web3.eth.net.isListening();
    console.log(`Connected to node: ${isConnected}`);
    
    // Get network info
    const networkId = await web3.eth.net.getId();
    const blockNumber = await web3.eth.getBlockNumber();
    console.log(`Network ID: ${networkId}, Current block: ${blockNumber}`);
    
    // Get accounts
    const accounts = await web3.eth.getAccounts();
    if (accounts.length === 0) {
      throw new Error('No accounts found on the node');
    }
    
    const accountAddress = accounts[0];
    console.log(`Using account: ${accountAddress}`);
    
    // Check account balance
    const balance = await web3.eth.getBalance(accountAddress);
    console.log(`Account balance: ${web3.utils.fromWei(balance, 'ether')} ETH`);
    
    // Unlock account if needed
    try {
      await web3.eth.personal.unlockAccount(accountAddress, ACCOUNT_PASSWORD, 600);
      console.log('Account unlocked successfully');
    } catch (error) {
      console.warn(`Warning: Could not unlock account: ${error.message}`);
      console.log('Proceeding anyway as the account might already be unlocked in the node...');
    }
    
    // Create contract instance
    const SimpleStorage = new web3.eth.Contract(contractABI);
    
    // Deploy contract
    console.log('Deploying SimpleStorage contract...');
    const deployTx = SimpleStorage.deploy({
      data: contractBytecode
    });
    
    const gas = await deployTx.estimateGas({ from: accountAddress });
    console.log(`Estimated gas: ${gas}`);
    
    const deployedContract = await deployTx.send({
      from: accountAddress,
      gas: Math.floor(gas * 1.1) // Add 10% buffer
    });
    
    console.log(`Contract deployed at address: ${deployedContract.options.address}`);
    
    // Test contract
    console.log('Testing contract...');
    
    // Store a value
    console.log('Storing value 42...');
    await deployedContract.methods.store(42).send({ from: accountAddress });
    
    // Retrieve the value
    const value = await deployedContract.methods.retrieve().call();
    console.log(`Retrieved value: ${value}`);
    
    if (value == 42) {
      console.log('Contract test successful!');
    } else {
      console.log('Contract test failed: retrieved value does not match stored value');
    }
    
    console.log('Deployment and testing completed successfully');
    console.log(`Contract address for future reference: ${deployedContract.options.address}`);
    
  } catch (error) {
    console.error('Error:', error);
    process.exit(1);
  }
}

// Run the script
main();
