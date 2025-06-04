// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract FiatLoanMatcher {
    uint public loanCounter;

    enum LoanStatus { Requested, Funded, Repaid }

    struct Loan {
        uint id;
        address borrower;
        address lender;
        string currency; // e.g., "USD", "NGN"
        uint amount;     // in smallest unit (e.g., cents or kobo)
        uint interest;   // flat interest amount
        uint duration;   // in seconds
        uint createdAt;
        LoanStatus status;
    }

    mapping(uint => Loan) public loans;

    event LoanRequested(
        uint indexed loanId,
        address indexed borrower,
        string currency,
        uint amount,
        uint interest,
        uint duration
    );

    event LoanFunded(uint indexed loanId, address indexed lender);
    event LoanRepaid(uint indexed loanId);

    modifier onlyBorrower(uint _loanId) {
        require(msg.sender == loans[_loanId].borrower, "Only borrower can call this");
        _;
    }

    modifier onlyLender(uint _loanId) {
        require(msg.sender == loans[_loanId].lender, "Only lender can call this");
        _;
    }

    function requestLoan(
        string memory _currency,
        uint _amount,
        uint _interest,
        uint _duration
    ) external {
        require(_amount > 0, "Amount must be greater than zero");

        loanCounter += 1;

        loans[loanCounter] = Loan({
            id: loanCounter,
            borrower: msg.sender,
            lender: address(0),
            currency: _currency,
            amount: _amount,
            interest: _interest,
            duration: _duration,
            createdAt: block.timestamp,
            status: LoanStatus.Requested
        });

        emit LoanRequested(loanCounter, msg.sender, _currency, _amount, _interest, _duration);
    }

    function fundLoan(uint _loanId) external {
        Loan storage loan = loans[_loanId];
        require(loan.status == LoanStatus.Requested, "Loan must be requested");
        require(loan.borrower != msg.sender, "Borrower cannot fund their own loan");

        loan.lender = msg.sender;
        loan.status = LoanStatus.Funded;

        emit LoanFunded(_loanId, msg.sender);
    }

    function markRepaid(uint _loanId) external onlyBorrower(_loanId) {
        Loan storage loan = loans[_loanId];
        require(loan.status == LoanStatus.Funded, "Loan must be funded");

        loan.status = LoanStatus.Repaid;

        emit LoanRepaid(_loanId);
    }

    function getLoanDetails(uint _loanId) external view returns (
        uint id,
        address borrower,
        address lender,
        string memory currency,
        uint amount,
        uint interest,
        uint duration,
        uint createdAt,
        LoanStatus status
    ) {
        Loan storage loan = loans[_loanId];
        return (
            loan.id,
            loan.borrower,
            loan.lender,
            loan.currency,
            loan.amount,
            loan.interest,
            loan.duration,
            loan.createdAt,
            loan.status
        );
    }
}
