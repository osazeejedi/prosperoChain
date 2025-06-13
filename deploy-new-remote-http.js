const Web3 = require('web3');
const fs = require('fs');
const path = require('path');

// Connect to the GoQuorum node on the new droplet
const web3 = new Web3('http://167.99.207.201:22000');

// Read the SimpleStorage contract source code
const contractSource = fs.readFileSync(path.join(__dirname, 'SimpleStorage.sol'), 'utf8');

// Compile the contract
const solc = require('solc');
const input = {
  language: 'Solidity',
  sources: {
    'SimpleStorage.sol': {
      content: contractSource
    }
  },
  settings: {
    outputSelection: {
      '*': {
        '*': ['*']
      }
    }
  }
};

console.log('Compiling the contract...');
const compiledContract = JSON.parse(solc.compile(JSON.stringify(input)));
const contractABI = compiledContract.contracts['SimpleStorage.sol']['SimpleStorage'].abi;
const contractBytecode = '0x' + compiledContract.contracts['SimpleStorage.sol']['SimpleStorage'].evm.bytecode.object;

// Deploy the contract
async function deployContract() {
  try {
    // Get accounts
    const accounts = await web3.eth.getAccounts();
    console.log('Available accounts:', accounts);

    // Deploy the contract
    console.log('Deploying the contract...');
    const contract = new web3.eth.Contract(contractABI);
    const deployTx = contract.deploy({
      data: contractBytecode,
      arguments: [42]  // Initial value for SimpleStorage
    });

    // Estimate gas
    const gas = await deployTx.estimateGas();
    console.log('Estimated gas:', gas);

    // Send the transaction
    const deployedContract = await deployTx.send({
      from: accounts[0],
      gas
    });

    console.log('Contract deployed at address:', deployedContract.options.address);

    // Test the contract
    console.log('Testing the contract...');
    const storedValue = await deployedContract.methods.get().call();
    console.log('Initial stored value:', storedValue);

    // Update the value
    console.log('Updating the stored value...');
    await deployedContract.methods.set(100).send({ from: accounts[0] });

    // Get the updated value
    const updatedValue = await deployedContract.methods.get().call();
    console.log('Updated stored value:', updatedValue);

    console.log('Contract deployment and testing completed successfully!');
  } catch (error) {
    console.error('Error deploying or testing the contract:', error);
  }
}

deployContract();
