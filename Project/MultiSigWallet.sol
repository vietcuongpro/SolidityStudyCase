/*
- create a multi-sig (signature) wallet. The wallet owners can
    submit a transaction
    approve and revoke approval of pending transactions
    anyone can execute a transaction after enough owners has approved it.
*/

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.10;

contract MultiSigWallet {
    event Deposit(address indexed sender, uint amount);
    event Submit(uint indexed txId);
    event Approve(address indexed owner, uint indexed txId);
    event Revoke(address indexed owner, uint indexed txId);
    event Execute(uint indexed txId);

    struct Transaction {
        address to;
        uint value; // ether send
        bytes data;
        bool executed;
    }

    address[] public owners;
    mapping(address => bool) public isOwner; // is owner of the wallet
    uint public requiredApprovals; // Number of required approvals for tx to executed
    
    Transaction[] public transactions;
    mapping(uint => mapping(address => bool)) public isApproved; // uint here means txId

    modifier onlyOwner() {
        require(isOwner[msg.sender], "Not Owner");
        _;
    }

    modifier txExist(uint _txId) {
        require(_txId < transactions.length, "Transaction ID not existed");
        _;
    }

    modifier notApprove(uint _txId) {
        require(!isApproved[_txId][msg.sender], "Already approved!");
        _;
    }

    modifier notExecute(uint _txId) {
        require(!transactions[_txId].executed, "Already executed!");
        _;
    }

    // memory: variable is in memory & it exists while a function is being called
    constructor(address[] memory _owners, uint _requiredApprovals) {
        require(_owners.length > 0, "There is no owner!");
        require(_requiredApprovals > 0 && requiredApprovals <= _owners.length, 
            "Number of required approvals not in range (0,number of owners]");
        
        for (uint i = 0; i < _owners.length; i++) {
            address temp = _owners[i];
            require(temp != address(0), "Invalid owner!");
            require(!isOwner[temp], "Owner already existed!");
            
            owners.push(temp);
            isOwner[temp] = true;
        }
        requiredApprovals = _requiredApprovals;
    }

    receive() external payable {
        //emit Deposit(msg.sender, msg.value);
    }

    // _data will be sent to address _to
    // calldata: special data location contains function args, only available for external function
    function submit(address _to, uint _value, bytes calldata _data) external onlyOwner {
        transactions.push(Transaction({
            to: _to,
            value: _value,
            data: _data,
            executed: false            
        }));
        emit Submit(transactions.length-1);
    }

    function approve(uint _txId) external onlyOwner txExist(_txId) notApprove(_txId) notExecute(_txId) {
        isApproved[_txId][msg.sender] = true;
        emit Approve(msg.sender, _txId);
    }

    function countApprovals(uint _txId) public txExist(_txId) view returns (uint count) {
        for (uint i = 0; i < owners.length; i++) {
            if (isApproved[_txId][owners[i]]) count++;
        }
    }

    function execute(uint _txId) external txExist(_txId) notExecute(_txId) {
        require(countApprovals(_txId) >= requiredApprovals, "Not enough approvals!");
        Transaction storage theTransaction = transactions[_txId];

        theTransaction.executed = true; 

        (bool sent, ) = theTransaction.to.call{value: theTransaction.value}(
            theTransaction.data
        );
        require(sent, "Transaction failed!");       
        
        emit Execute(_txId);
    }

    function revoke(uint _txId) external onlyOwner txExist(_txId) notExecute(_txId) {
        require(isApproved[_txId][msg.sender], "Nothing to revoke!");
        isApproved[_txId][msg.sender] = false;
        emit Revoke(msg.sender, _txId);
    }

    function checkBalance() public view returns (uint) {
        return address(this).balance;
    }
}
