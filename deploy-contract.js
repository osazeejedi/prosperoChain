// Deploy HelloWorld contract to the GoQuorum network
// Usage: docker exec -it goquorum-qbft-network-node-0-1 geth --exec "loadScript('/qdata/deploy-contract.js')" attach /qdata/dd/geth.ipc

// Unlock the account
personal.unlockAccount(eth.accounts[0], "", 0);

// Simple HelloWorld contract source code
var helloWorldSource = `
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract HelloWorld {
    string public greet = "Hello, Quorum!";

    function setGreeting(string memory _greet) public {
        greet = _greet;
    }

    function getGreeting() public view returns (string memory) {
        return greet;
    }
}
`;

// Compile the contract
console.log("Compiling the contract...");
var helloWorldCompiled = eth.compile.solidity(helloWorldSource);

// Get the contract data
var helloWorldContract = eth.contract(helloWorldCompiled.HelloWorld.info.abiDefinition);
var helloWorldBytecode = helloWorldCompiled.HelloWorld.code;

// Deploy the contract
var deployTransactionObject = { from: eth.accounts[0], data: helloWorldBytecode, gas: 4700000 };

console.log("Deploying the contract...");
var helloWorld = helloWorldContract.new(deployTransactionObject);

// Wait for the contract to be mined
console.log("Waiting for the contract to be mined...");
var receipt = null;
while (receipt === null) {
  receipt = eth.getTransactionReceipt(helloWorld.transactionHash);
  if (receipt === null) {
    console.log("Waiting...");
  }
}

console.log("Contract deployed at address: " + helloWorld.address);

// Test the contract
console.log("Testing the contract...");
console.log("Initial greeting: " + helloWorld.greet());

console.log("Setting new greeting...");
helloWorld.setGreeting("Hello, GoQuorum QBFT Network!", {from: eth.accounts[0], gas: 4700000});

console.log("New greeting: " + helloWorld.greet());

console.log("Contract deployment and testing completed successfully!");
