// check-contract.js - Check if SimpleStorage contract is deployed and working
// This script uses web3.js to connect to the GoQuorum node via HTTP RPC
// Run with: node check-contract.js <contract-address>

const Web3 = require('web3');

// Configuration
const RPC_URL = 'http://localhost:22000'; // Node 0 HTTP RPC endpoint

// Contract ABI
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

// Main function
async function main() {
  try {
    // Get contract address from command line
    const contractAddress = process.argv[2];
    if (!contractAddress) {
      console.error('Please provide a contract address as a command line argument');
      process.exit(1);
    }

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
    
    // Create contract instance
    console.log(`Checking contract at address: ${contractAddress}`);
    const simpleStorage = new web3.eth.Contract(contractABI, contractAddress);
    
    // Retrieve the value
    const value = await simpleStorage.methods.retrieve().call();
    console.log(`Retrieved value: ${value}`);
    
    console.log('Contract check completed successfully');
    
  } catch (error) {
    console.error('Error:', error);
    process.exit(1);
  }
}

// Run the script
main();
