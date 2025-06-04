// example-backend-server.js
// A simple Express server that demonstrates how to interact with the FiatLoanMatcher contract

const express = require('express');
const bodyParser = require('body-parser');
const Web3 = require('web3');

// Create Express app
const app = express();
app.use(bodyParser.json());

// Configure web3 connection to Quorum
const web3 = new Web3('http://localhost:22000'); // Replace with your Quorum node URL

// FiatLoanMatcher contract ABI (partial, focusing on the methods we need)
const contractABI = [
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
        "components": [
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
        "internalType": "struct FiatLoanMatcher.Loan",
        "name": "",
        "type": "tuple"
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

// Contract address (replace with your deployed contract address)
const contractAddress = '0x1234567890123456789012345678901234567890'; // Example address
const contract = new web3.eth.Contract(contractABI, contractAddress);

// Get default account for transactions
let defaultAccount;

// Initialize web3 and get accounts
async function initWeb3() {
  try {
    const accounts = await web3.eth.getAccounts();
    if (accounts.length === 0) {
      console.error('No accounts found on the node');
      process.exit(1);
    }
    defaultAccount = accounts[0];
    console.log(`Using account: ${defaultAccount}`);
  } catch (error) {
    console.error('Error initializing web3:', error);
    process.exit(1);
  }
}

// API Routes

// Get all loans (up to the current loan counter)
app.get('/api/loans', async (req, res) => {
  try {
    const loanCounter = await contract.methods.loanCounter().call();
    const loans = [];
    
    for (let i = 1; i <= loanCounter; i++) {
      const loan = await contract.methods.getLoanDetails(i).call();
      loans.push({
        id: loan.id,
        borrower: loan.borrower,
        lender: loan.lender,
        currency: loan.currency,
        amount: loan.amount,
        interest: loan.interest,
        duration: loan.duration,
        createdAt: loan.createdAt,
        status: ['Requested', 'Funded', 'Repaid'][loan.status]
      });
    }
    
    res.json({ loans });
  } catch (error) {
    console.error('Error fetching loans:', error);
    res.status(500).json({ error: 'Failed to fetch loans' });
  }
});

// Get a specific loan by ID
app.get('/api/loans/:id', async (req, res) => {
  try {
    const loanId = req.params.id;
    const loan = await contract.methods.getLoanDetails(loanId).call();
    
    res.json({
      id: loan.id,
      borrower: loan.borrower,
      lender: loan.lender,
      currency: loan.currency,
      amount: loan.amount,
      interest: loan.interest,
      duration: loan.duration,
      createdAt: loan.createdAt,
      status: ['Requested', 'Funded', 'Repaid'][loan.status]
    });
  } catch (error) {
    console.error(`Error fetching loan ${req.params.id}:`, error);
    res.status(500).json({ error: 'Failed to fetch loan' });
  }
});

// Request a new loan
app.post('/api/loans', async (req, res) => {
  try {
    const { currency, amount, interest, duration } = req.body;
    
    // Input validation
    if (!currency || !amount || !interest || !duration) {
      return res.status(400).json({ error: 'Missing required fields' });
    }
    
    // Send transaction
    const tx = await contract.methods.requestLoan(
      currency, amount, interest, duration
    ).send({ from: defaultAccount });
    
    // Extract loan ID from event
    const loanId = tx.events.LoanRequested.returnValues.loanId;
    
    res.status(201).json({ 
      message: 'Loan requested successfully',
      loanId,
      transactionHash: tx.transactionHash
    });
  } catch (error) {
    console.error('Error requesting loan:', error);
    res.status(500).json({ error: 'Failed to request loan' });
  }
});

// Fund a loan
app.post('/api/loans/:id/fund', async (req, res) => {
  try {
    const loanId = req.params.id;
    
    // Optional: Use a different account for funding
    const lenderAccount = req.body.lenderAccount || defaultAccount;
    
    // Send transaction
    const tx = await contract.methods.fundLoan(loanId)
      .send({ from: lenderAccount });
    
    res.json({ 
      message: `Loan ${loanId} funded successfully`,
      transactionHash: tx.transactionHash
    });
  } catch (error) {
    console.error(`Error funding loan ${req.params.id}:`, error);
    res.status(500).json({ error: 'Failed to fund loan' });
  }
});

// Mark a loan as repaid
app.post('/api/loans/:id/repay', async (req, res) => {
  try {
    const loanId = req.params.id;
    
    // Send transaction
    const tx = await contract.methods.markRepaid(loanId)
      .send({ from: defaultAccount });
    
    res.json({ 
      message: `Loan ${loanId} marked as repaid`,
      transactionHash: tx.transactionHash
    });
  } catch (error) {
    console.error(`Error repaying loan ${req.params.id}:`, error);
    res.status(500).json({ error: 'Failed to mark loan as repaid' });
  }
});

// Start the server
const PORT = process.env.PORT || 3000;

// Initialize web3 and start server
initWeb3().then(() => {
  app.listen(PORT, () => {
    console.log(`Server running on port ${PORT}`);
    console.log(`Using FiatLoanMatcher contract at ${contractAddress}`);
  });
}).catch(error => {
  console.error('Failed to initialize:', error);
});

// Event listeners for contract events
function setupEventListeners() {
  // Listen for new loan requests
  contract.events.LoanRequested({})
    .on('data', (event) => {
      console.log(`New loan requested: ID ${event.returnValues.loanId}`);
      console.log(`Borrower: ${event.returnValues.borrower}`);
      console.log(`Currency: ${event.returnValues.currency}`);
      console.log(`Amount: ${event.returnValues.amount}`);
    })
    .on('error', console.error);

  // Listen for funded loans
  contract.events.LoanFunded({})
    .on('data', (event) => {
      console.log(`Loan funded: ID ${event.returnValues.loanId}`);
      console.log(`Lender: ${event.returnValues.lender}`);
    })
    .on('error', console.error);

  // Listen for repaid loans
  contract.events.LoanRepaid({})
    .on('data', (event) => {
      console.log(`Loan repaid: ID ${event.returnValues.loanId}`);
    })
    .on('error', console.error);
}

// Setup event listeners
setupEventListeners();
