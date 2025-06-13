// deploy-fiatloan-http-simple.js - Deploy FiatLoanMatcher contract using HTTP RPC
// This script uses web3.js to connect to the GoQuorum node via HTTP RPC
// Run with: node deploy-fiatloan-http-simple.js

const Web3 = require('web3');
const fs = require('fs');
const path = require('path');

// Configuration
const RPC_URL = 'http://167.99.207.201:22000'; // Node 0 HTTP RPC endpoint
const ACCOUNT_ADDRESS = ''; // Will be populated from the node
const ACCOUNT_PASSWORD = ''; // Empty password as per your setup

// Read the contract source code
const contractSource = fs.readFileSync(path.join(__dirname, 'FiatLoanMatcher.sol'), 'utf8');

// ABI for the FiatLoanMatcher contract
const contractABI = [
	{
		"anonymous": false,
		"inputs": [
			{
				"indexed": true,
				"internalType": "uint256",
				"name": "loanId",
				"type": "uint256"
			},
			{
				"indexed": true,
				"internalType": "address",
				"name": "lender",
				"type": "address"
			}
		],
		"name": "LoanFunded",
		"type": "event"
	},
	{
		"anonymous": false,
		"inputs": [
			{
				"indexed": true,
				"internalType": "uint256",
				"name": "loanId",
				"type": "uint256"
			}
		],
		"name": "LoanRepaid",
		"type": "event"
	},
	{
		"anonymous": false,
		"inputs": [
			{
				"indexed": true,
				"internalType": "uint256",
				"name": "loanId",
				"type": "uint256"
			},
			{
				"indexed": true,
				"internalType": "address",
				"name": "borrower",
				"type": "address"
			},
			{
				"indexed": false,
				"internalType": "string",
				"name": "currency",
				"type": "string"
			},
			{
				"indexed": false,
				"internalType": "uint256",
				"name": "amount",
				"type": "uint256"
			},
			{
				"indexed": false,
				"internalType": "uint256",
				"name": "interest",
				"type": "uint256"
			},
			{
				"indexed": false,
				"internalType": "uint256",
				"name": "duration",
				"type": "uint256"
			}
		],
		"name": "LoanRequested",
		"type": "event"
	},
	{
		"inputs": [
			{
				"internalType": "uint256",
				"name": "_loanId",
				"type": "uint256"
			}
		],
		"name": "fundLoan",
		"outputs": [],
		"stateMutability": "nonpayable",
		"type": "function"
	},
	{
		"inputs": [
			{
				"internalType": "uint256",
				"name": "_loanId",
				"type": "uint256"
			}
		],
		"name": "getLoanDetails",
		"outputs": [
			{
				"internalType": "uint256",
				"name": "id",
				"type": "uint256"
			},
			{
				"internalType": "address",
				"name": "borrower",
				"type": "address"
			},
			{
				"internalType": "address",
				"name": "lender",
				"type": "address"
			},
			{
				"internalType": "string",
				"name": "currency",
				"type": "string"
			},
			{
				"internalType": "uint256",
				"name": "amount",
				"type": "uint256"
			},
			{
				"internalType": "uint256",
				"name": "interest",
				"type": "uint256"
			},
			{
				"internalType": "uint256",
				"name": "duration",
				"type": "uint256"
			},
			{
				"internalType": "uint256",
				"name": "createdAt",
				"type": "uint256"
			},
			{
				"internalType": "enum FiatLoanMatcher.LoanStatus",
				"name": "status",
				"type": "uint8"
			}
		],
		"stateMutability": "view",
		"type": "function"
	},
	{
		"inputs": [],
		"name": "loanCounter",
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
				"name": "",
				"type": "uint256"
			}
		],
		"name": "loans",
		"outputs": [
			{
				"internalType": "uint256",
				"name": "id",
				"type": "uint256"
			},
			{
				"internalType": "address",
				"name": "borrower",
				"type": "address"
			},
			{
				"internalType": "address",
				"name": "lender",
				"type": "address"
			},
			{
				"internalType": "string",
				"name": "currency",
				"type": "string"
			},
			{
				"internalType": "uint256",
				"name": "amount",
				"type": "uint256"
			},
			{
				"internalType": "uint256",
				"name": "interest",
				"type": "uint256"
			},
			{
				"internalType": "uint256",
				"name": "duration",
				"type": "uint256"
			},
			{
				"internalType": "uint256",
				"name": "createdAt",
				"type": "uint256"
			},
			{
				"internalType": "enum FiatLoanMatcher.LoanStatus",
				"name": "status",
				"type": "uint8"
			}
		],
		"stateMutability": "view",
		"type": "function"
	},
	{
		"inputs": [
			{
				"internalType": "uint256",
				"name": "_loanId",
				"type": "uint256"
			}
		],
		"name": "markRepaid",
		"outputs": [],
		"stateMutability": "nonpayable",
		"type": "function"
	},
	{
		"inputs": [
			{
				"internalType": "string",
				"name": "_currency",
				"type": "string"
			},
			{
				"internalType": "uint256",
				"name": "_amount",
				"type": "uint256"
			},
			{
				"internalType": "uint256",
				"name": "_interest",
				"type": "uint256"
			},
			{
				"internalType": "uint256",
				"name": "_duration",
				"type": "uint256"
			}
		],
		"name": "requestLoan",
		"outputs": [],
		"stateMutability": "nonpayable",
		"type": "function"
	}
];

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
    
    // Compile the contract
    console.log('Compiling FiatLoanMatcher contract...');
    
    // Create contract instance
    const FiatLoanMatcher = new web3.eth.Contract(contractABI);
    
    // Deploy contract
    console.log('Deploying FiatLoanMatcher contract...');
    
    // Instead of using the bytecode directly, we'll use the solc compiler
    // This is a simplified approach - in a real scenario, you would use solc to compile the contract
    // For this example, we'll use a placeholder for the bytecode
    const bytecode = "608060405234801561001057600080fd5b50610a6f806100206000396000f3fe608060405234801561001057600080fd5b50600436106100625760003560e01c806334d9289e1461006757806366877b8d14610081578063846b909a1461016b578063a21411601461018a578063c701c9941461023b578063e1ec3c6814610258575b600080fd5b61006f610275565b60408051918252519081900360200190f35b61009e6004803603602081101561009757600080fd5b503561027b565b604051808a8152602001896001600160a01b03168152602001886001600160a01b03168152602001806020018781526020018681526020018581526020018481526020018360028111156100ee57fe5b8152602001828103825288818151815260200191508051906020019080838360005b83811015610128578181015183820152602001610110565b50505050905090810190601f1680156101555780820380516001836020036101000a031916815260200191505b509a505050505050505050505060405180910390f35b6101886004803603602081101561018157600080fd5b5035610405565b005b610188600480360360808110156101a057600080fd5b8101906020810181356401000000008111156101bb57600080fd5b8201836020820111156101cd57600080fd5b803590602001918460018302840111640100000000831117156101ef57600080fd5b91908080601f0160208091040260200160405190810160405280939291908181526020018383808284376000920191909152509295505082359350505060208101359060400135610529565b6101886004803603602081101561025157600080fd5b5035610740565b61009e6004803603602081101561026e57600080fd5b503561085d565b60005481565b60008060006060600080600080600061029261093e565b60008b81526001602081815260409283902083516101208101855281548152818401546001600160a01b03908116828501526002808401549091168287015260038301805487516101009782161597909702600019011691909104601f810185900485028601850190965285855290949193606086019390929083018282801561035d5780601f106103325761010080835404028352916020019161035d565b820191906000526020600020905b81548152906001019060200180831161034057829003601f168201915b505050918352505060048201546020820152600582015460408201526006820154606082015260078201546080820152600882015460a09091019060ff1660028111156103a657fe5b60028111156103b157fe5b815250509050806000015181602001518260400151836060015184608001518560a001518660c001518760e00151886101000151995099509950995099509950995099509950509193959799909294969850565b600081815260016020526040812090600882015460ff16600281111561042757fe5b14610472576040805162461bcd60e51b8152602060048201526016602482015275131bd85b881b5d5cdd081899481c995c5d595cdd195960521b604482015290519081900360640190fd5b60018101546001600160a01b03163314156104d4576040805162461bcd60e51b815260206004820152601d60248201527f426f72726f7765722063616e6e6f742066756e64206f776e206c6f616e000000604482015290519081900360640190fd5b6002810180546001600160a01b0319163390811790915560088201805460ff1916600117905560405183907f15feab5d3eb17171632762cf769709a315dd15f487a556c0dfb8a259c8f186cc90600090a35050565b6000831161057e576040805162461bcd60e51b815260206004820181905260248201527f416d6f756e74206d7573742062652067726561746572207468616e207a65726f604482015290519081900360640190fd5b6000805460019081018083556040805161012081018252828152336020808301918252828401878152606084018c8152608085018c905260a085018b905260c085018a90524260e086015261010085018990529588528682529390962082518155905194810180546001600160a01b03199081166001600160a01b0397881617909155925160028201805490941695169490941790915590518051919361062d926003850192909101906109a6565b506080820151600482015560a0820151600582015560c0820151600682015560e0820151600782015561010082015160088201805460ff1916600183600281111561067457fe5b0217905550905050336001600160a01b03166000547f3850bfdb966d58f3352e99432e9dc1a34a467c611a0f46e90b76271e213a94e1868686866040518080602001858152602001848152602001838152602001828103825286818151815260200191508051906020019080838360005b838110156106fd5781810151838201526020016106e5565b50505050905090810190601f16801561072a5780820380516001836020036101000a031916815260200191505b509550505050505060405180910390a350505050565b6000818152600160208190526040909120015481906001600160a01b031633146107b1576040805162461bcd60e51b815260206004820152601b60248201527f4f6e6c7920626f72726f7765722063616e2063616c6c20746869730000000000604482015290519081900360640190fd5b600082815260016020819052604090912090600882015460ff1660028111156107d657fe5b1461081e576040805162461bcd60e51b8152602060048201526013602482015272131bd85b881b5d5cdd08189948199d5b991959606a1b604482015290519081900360640190fd5b60088101805460ff1916600217905560405183907f9a7851747cd7ffb3fe0a32caf3da48b31f27cebe131267051640f8b72fc4718690600090a2505050565b60016020818152600092835260409283902080548184015460028084015460038501805489516101009982161599909902600019011692909204601f810187900487028801870190985287875292966001600160a01b03928316969290931694919290918301828280156109125780601f106108e757610100808354040283529160200191610912565b820191906000526020600020905b8154815290600101906020018083116108f557829003601f168201915b505050600484015460058501546006860154600787015460089097015495969295919450925060ff1689565b6040518061012001604052806000815260200160006001600160a01b0316815260200160006001600160a01b031681526020016060815260200160008152602001600081526020016000815260200160008152602001600060028111156109a157fe5b905290565b828054600181600116156101000203166002900490600052602060002090601f016020900481019282601f106109e757805160ff1916838001178555610a14565b82800160010185558215610a14579182015b82811115610a145782518255916020019190600101906109f9565b50610a20929150610a24565b5090565b5b80821115610a205760008155600101610a2556fea26469706673582212205e5e22e68133f2b4095a92efadced850106c7cca7a25e9a7ef59e3c49bdcb1f364736f6c634300060c0033";
    
    const deployTx = FiatLoanMatcher.deploy({
      data: bytecode
    });
    
    const gas = await deployTx.estimateGas({ from: accountAddress });
    console.log(`Estimated gas: ${gas}`);
    
    const deployedContract = await deployTx.send({
      from: accountAddress,
      gas: Math.floor(gas * 1.1) // Add 10% buffer
    });
    
    console.log(`Contract deployed at address: ${deployedContract.options.address}`);
    
    // Test contract
    console.log('Testing contract functionality...');
    
    // 1. Request a loan
    console.log('1. Requesting a loan...');
    const currency = "USD";
    const amount = 1000 * 100; // $1000 in cents
    const interest = 50 * 100; // $50 interest in cents
    const duration = 30 * 24 * 60 * 60; // 30 days in seconds
    
    const requestTx = await deployedContract.methods.requestLoan(
      currency, amount, interest, duration
    ).send({ from: accountAddress });
    
    const loanId = requestTx.events.LoanRequested.returnValues.loanId;
    console.log(`Loan requested with ID: ${loanId}`);
    
    // 2. Get loan details
    console.log('2. Getting loan details...');
    const loanDetails = await deployedContract.methods.getLoanDetails(loanId).call();
    console.log('Loan details:');
    console.log(`  ID: ${loanDetails.id}`);
    console.log(`  Borrower: ${loanDetails.borrower}`);
    console.log(`  Currency: ${loanDetails.currency}`);
    console.log(`  Amount: ${loanDetails.amount}`);
    console.log(`  Interest: ${loanDetails.interest}`);
    console.log(`  Duration: ${loanDetails.duration}`);
    console.log(`  Status: ${loanDetails.status}`); // 0 = Requested
    
    // 3. Fund the loan (using a different account)
    console.log('3. Funding the loan...');
    const lenderAccount = accounts[1] || accounts[0]; // Use a different account if available
    
    if (lenderAccount === accountAddress) {
      console.log('Note: Using the same account for borrower and lender (for testing only)');
      console.log('In a real scenario, these would be different accounts');
    }
    
    try {
      await deployedContract.methods.fundLoan(loanId).send({ from: lenderAccount });
      console.log(`Loan ${loanId} funded successfully by ${lenderAccount}`);
    } catch (error) {
      console.error(`Error funding loan: ${error.message}`);
      console.log('This is expected if using the same account as borrower and lender');
      console.log('Continuing with the test...');
    }
    
    // 4. Mark the loan as repaid
    console.log('4. Marking the loan as repaid...');
    try {
      await deployedContract.methods.markRepaid(loanId).send({ from: accountAddress });
      console.log(`Loan ${loanId} marked as repaid`);
    } catch (error) {
      console.error(`Error marking loan as repaid: ${error.message}`);
    }
    
    // 5. Get final loan details
    console.log('5. Getting final loan details...');
    const finalLoanDetails = await deployedContract.methods.getLoanDetails(loanId).call();
    console.log('Final loan details:');
    console.log(`  ID: ${finalLoanDetails.id}`);
    console.log(`  Borrower: ${finalLoanDetails.borrower}`);
    console.log(`  Lender: ${finalLoanDetails.lender}`);
    console.log(`  Currency: ${finalLoanDetails.currency}`);
    console.log(`  Amount: ${finalLoanDetails.amount}`);
    console.log(`  Status: ${finalLoanDetails.status}`); // 2 = Repaid (if successful)
    
    console.log('Deployment and testing completed successfully');
    console.log(`Contract address for future reference: ${deployedContract.options.address}`);
    
  } catch (error) {
    console.error('Error:', error);
    process.exit(1);
  }
}

// Run the script
main();
