// Deploy SimpleStorage contract to the GoQuorum network
// Usage: docker exec -it goquorum-qbft-network-node-0-1 geth --exec "loadScript('/qdata/deploy-simple-storage.js')" attach /qdata/dd/geth.ipc

// Add environment information for debugging
console.log("=== Environment Information ===");
console.log("Node info: " + admin.nodeInfo.enode);
console.log("Protocol version: " + eth.protocolVersion);
console.log("Network ID: " + net.version);
console.log("Block number: " + eth.blockNumber);
console.log("Using account: " + eth.accounts[0]);
console.log("Account balance: " + web3.fromWei(eth.getBalance(eth.accounts[0]), "ether") + " ETH");
console.log("==============================");

// Unlock the account
console.log("Unlocking account...");
var unlocked = personal.unlockAccount(eth.accounts[0], "", 0);
console.log("Account unlocked: " + unlocked);

// Pre-compiled contract data
var simpleStorageABI = [
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

var simpleStorageBytecode = "0x608060405234801561001057600080fd5b50610150806100206000396000f3fe608060405234801561001057600080fd5b50600436106100365760003560e01c80632e64cec11461003b5780636057361d14610059575b600080fd5b610043610075565b60405161005091906100a1565b60405180910390f35b610073600480360381019061006e91906100ed565b61007e565b005b60008054905090565b8060008190555050565b6000819050919050565b61009b81610088565b82525050565b60006020820190506100b66000830184610092565b92915050565b600080fd5b6100ca81610088565b81146100d557600080fd5b50565b6000813590506100e7816100c1565b92915050565b600060208284031215610103576101026100bc565b5b6000610111848285016100d8565b9150509291505056fea2646970667358221220322c78243e61b783558509c9cc22cb8493dde6925aa5e89a08cdf6e22f279ef164736f6c63430008120033";

// Deploy the contract
console.log("Creating contract object...");
var SimpleStorageContract = eth.contract(simpleStorageABI);
var deployTransactionObject = { from: eth.accounts[0], data: simpleStorageBytecode, gas: 4700000 };

console.log("Deploying the SimpleStorage contract...");
var deployTx = SimpleStorageContract.new(deployTransactionObject);
var txHash = deployTx.transactionHash;

// Wait for the contract to be mined
console.log("Waiting for the contract to be mined (txHash: " + txHash + ")...");
var receipt = null;
var contractAddress = null;

// Poll for the receipt
for (var i = 0; i < 50 && receipt === null; i++) {
  receipt = eth.getTransactionReceipt(txHash);
  if (receipt !== null) {
    contractAddress = receipt.contractAddress;
    console.log("Contract mined! Address: " + contractAddress);
    break;
  }
  console.log("Waiting for transaction to be mined...");
  admin.sleep(2); // Sleep for 2 seconds between checks
}

if (contractAddress === null) {
  throw new Error("Failed to deploy contract - transaction not mined within timeout period");
}

// Add address validation and formatting
if (!contractAddress.startsWith('0x')) {
  contractAddress = '0x' + contractAddress;
}
console.log("Validating contract address: " + contractAddress);

// Ensure the address is valid
if (!/^0x[0-9a-fA-F]{40}$/.test(contractAddress)) {
  throw new Error("Invalid contract address format: " + contractAddress);
}

// Check if there's code at the address
var contractCode = eth.getCode(contractAddress);
console.log("Contract code at address: " + (contractCode === '0x' ? 'No code (not deployed)' : 'Code exists (length: ' + contractCode.length + ')'));

if (contractCode === '0x') {
  throw new Error("No code at contract address - deployment failed");
}

// Create a contract instance at the deployed address using web3.eth.contract
console.log("Creating contract instance...");
var simpleStorage = web3.eth.contract(simpleStorageABI).at(contractAddress);

// Check if contract has expected methods
console.log("Checking contract methods...");
console.log("Contract methods: " + Object.keys(simpleStorage).filter(k => typeof simpleStorage[k] === 'function').join(', '));

// Test the contract using try/catch to handle errors
console.log("Testing the contract...");
try {
  var initialValue = simpleStorage.retrieve();
  console.log("Initial value: " + initialValue);
} catch (e) {
  console.log("Error calling retrieve(): " + e);
  
  // Try alternative approach using direct call
  console.log("Trying direct call approach...");
  try {
    var retrieveData = web3.sha3("retrieve()").substring(0, 10); // Function signature
    var retrieveResult = eth.call({to: contractAddress, data: retrieveData});
    console.log("Direct call result: " + web3.toDecimal(retrieveResult));
  } catch (e2) {
    console.log("Direct call also failed: " + e2);
  }
}

console.log("Storing new value (42)...");
try {
  var storeTx = simpleStorage.store(42, {from: eth.accounts[0], gas: 4700000});
  console.log("Store transaction hash: " + storeTx);

  // Wait for the store transaction to be mined
  var storeReceipt = null;
  for (var i = 0; i < 20 && storeReceipt === null; i++) {
    storeReceipt = eth.getTransactionReceipt(storeTx);
    if (storeReceipt === null) {
      console.log("Waiting for store transaction to be mined...");
      admin.sleep(1);
    }
  }
  
  // Try to get the new value
  try {
    var newValue = simpleStorage.retrieve();
    console.log("New value: " + newValue);
  } catch (e) {
    console.log("Error calling retrieve() after store: " + e);
    
    // Try alternative approach
    try {
      var retrieveData = web3.sha3("retrieve()").substring(0, 10); // Function signature
      var retrieveResult = eth.call({to: contractAddress, data: retrieveData});
      console.log("Direct call result after store: " + web3.toDecimal(retrieveResult));
    } catch (e2) {
      console.log("Direct call after store also failed: " + e2);
    }
  }
} catch (e) {
  console.log("Error calling store(): " + e);
  
  // Try alternative approach for store
  try {
    console.log("Trying direct transaction approach for store...");
    var storeData = web3.sha3("store(uint256)").substring(0, 10) + 
                   "000000000000000000000000000000000000000000000000000000000000002a"; // 42 in hex
    var directStoreTx = eth.sendTransaction({
      from: eth.accounts[0],
      to: contractAddress,
      data: storeData,
      gas: 4700000
    });
    console.log("Direct store transaction hash: " + directStoreTx);
  } catch (e2) {
    console.log("Direct store transaction also failed: " + e2);
  }
}

console.log("Contract deployment and testing completed!");
console.log("Contract address for future reference: " + contractAddress);
