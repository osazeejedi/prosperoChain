# FiatLoanMatcher Contract

A smart contract for peer-to-peer fiat currency loans on the Quorum blockchain.

## Overview

The FiatLoanMatcher contract enables users to create, fund, and manage fiat currency loans on the blockchain. It serves as a decentralized matching platform for borrowers and lenders, while the actual fiat currency exchange happens off-chain.

## Features

- Create loan requests with specific currency, amount, interest, and duration
- Fund loans as a lender
- Mark loans as repaid
- View loan details
- Event-driven architecture for real-time updates

## Files

- `FiatLoanMatcher.sol`: The Solidity smart contract
- `deploy-fiatloan-http.js`: Script to deploy the contract using HTTP RPC
- `start-and-deploy-fiatloan.sh`: Script to start the network and deploy the contract
- `FIATLOAN_INTEGRATION.md`: Comprehensive integration guide for backend developers
- `example-backend-server.js`: Example Express server demonstrating contract integration

## Getting Started

### Prerequisites

- GoQuorum network running
- Node.js and npm installed
- Web3.js library installed

### Deployment

1. Start the Quorum network and deploy the contract:

```bash
./start-and-deploy-fiatloan.sh
```

2. Note the deployed contract address from the console output.

3. Update the contract address in your application code.

### Using the Example Backend Server

The example backend server provides a RESTful API for interacting with the contract:

1. Install dependencies:

```bash
npm install express body-parser web3
```

2. Update the contract address in `example-backend-server.js`.

3. Start the server:

```bash
node example-backend-server.js
```

4. Use the API endpoints:

- `GET /api/loans`: Get all loans
- `GET /api/loans/:id`: Get a specific loan
- `POST /api/loans`: Request a new loan
- `POST /api/loans/:id/fund`: Fund a loan
- `POST /api/loans/:id/repay`: Mark a loan as repaid

## Contract Lifecycle

1. **Loan Request**: A borrower creates a loan request specifying currency, amount, interest, and duration.
2. **Loan Funding**: A lender funds the loan, establishing the borrower-lender relationship.
3. **Off-chain Exchange**: The lender sends the fiat currency to the borrower through traditional means.
4. **Loan Repayment**: The borrower repays the loan off-chain and then marks it as repaid on the blockchain.

## Security Considerations

- The contract only handles the matching and status tracking of loans
- Actual fiat currency exchange happens off-chain
- Borrowers and lenders should establish trust or use external escrow services
- No collateral mechanism is implemented in this version

## Integration

For detailed integration instructions, see [FIATLOAN_INTEGRATION.md](./FIATLOAN_INTEGRATION.md).

## License

MIT
