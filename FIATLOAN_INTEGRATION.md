# FiatLoanMatcher Contract Integration Guide

This document provides guidance for integrating the FiatLoanMatcher smart contract with backend server applications. The FiatLoanMatcher contract enables peer-to-peer fiat currency loans on the blockchain.

## Contract Overview

The FiatLoanMatcher contract facilitates peer-to-peer fiat currency loans by matching borrowers and lenders. It handles the entire loan lifecycle from request to repayment.

### Loan Lifecycle

1. **Request**: A borrower requests a loan, specifying currency, amount, interest, and duration
2. **Fund**: A lender funds the loan, establishing the borrower-lender relationship
3. **Repay**: The borrower marks the loan as repaid after completing the off-chain payment

### Data Structures

#### Loan Struct

```solidity
struct Loan {
    uint id;
    address borrower;
    address lender;
    string currency; // e.g., "USD", "NGN"
    uint amount; // in smallest fiat unit (e.g., cents or kobo)
    uint interest; // absolute value, not percent
    uint duration; // in seconds
    uint createdAt;
    LoanStatus status;
}
```

#### LoanStatus Enum

```solidity
enum LoanStatus { Requested, Funded, Repaid }
```

### Events

The contract emits events at each stage of the loan lifecycle:

1. **LoanRequested**: When a borrower creates a new loan request
2. **LoanFunded**: When a lender funds a loan
3. **LoanRepaid**: When a borrower marks a loan as repaid

## Backend Integration Guide

### Setting Up a Connection

To interact with the FiatLoanMatcher contract, you'll need to establish a connection to the Quorum network:

```javascript
const Web3 = require('web3');
const web3 = new Web3('http://localhost:22000'); // Replace with your Quorum node URL

// Contract instance
const contractAddress = '0x...'; // Replace with deployed contract address
const FiatLoanMatcher = new web3.eth.Contract(contractABI, contractAddress);
```

## API Reference

### Functions

#### requestLoan

```javascript
// Request a loan
async function requestLoan(contract, account) {
  const currency = "USD";
  const amount = 1000 * 100; // $1000 in cents
  const interest = 50 * 100; // $50 interest in cents
  const duration = 30 * 24 * 60 * 60; // 30 days in seconds
  
  const tx = await contract.methods.requestLoan(
    currency, amount, interest, duration
  ).send({ from: account });
  
  const loanId = tx.events.LoanRequested.returnValues.loanId;
  console.log(`Loan requested with ID: ${loanId}`);
  return loanId;
}
```

#### fundLoan

```javascript
// Fund a loan
async function fundLoan(contract, account, loanId) {
  const tx = await contract.methods.fundLoan(loanId).send({ from: account });
  console.log(`Loan ${loanId} funded by ${account}`);
  return tx;
}
```

#### markRepaid

```javascript
// Mark a loan as repaid
async function markRepaid(contract, account, loanId) {
  const tx = await contract.methods.markRepaid(loanId).send({ from: account });
  console.log(`Loan ${loanId} marked as repaid`);
  return tx;
}
```

#### getLoanDetails

```javascript
// Get loan details
async function getLoanDetails(contract, loanId) {
  const loan = await contract.methods.getLoanDetails(loanId).call();
  console.log(`Loan ${loanId} details:`, loan);
  return loan;
}
```

## Event Listening

```javascript
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
```

## Security Considerations

1. **Input Validation**: Always validate user inputs before sending transactions to the contract
2. **Error Handling**: Implement proper error handling for all contract interactions
3. **Access Control**: Ensure only authorized users can perform sensitive operations
4. **Transaction Security**: Use secure methods for transaction signing and key management

## Testing Strategies

1. **Unit Testing**: Test individual contract functions in isolation
2. **Integration Testing**: Test the interaction between your backend and the contract
3. **End-to-End Testing**: Test the complete loan lifecycle from request to repayment
4. **Event Testing**: Verify that events are properly emitted and captured

## Deployment

To deploy the FiatLoanMatcher contract to your Quorum network, use the provided deployment script:

```bash
node deploy-fiatloan-http.js
```

This script will:
1. Connect to the Quorum node via HTTP RPC
2. Deploy the contract
3. Run basic tests to verify functionality
4. Output the deployed contract address for future reference
