// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "./IBEP20.sol";

// Multisig wallet to keep treasury fund SAFU
// Will require owners / 2 + 1 confirmations to execute
contract ScholarDogeTreasury {
    struct Transaction {
        address to;
        uint256 value;
        bytes data;
        bool executed;
        uint8 numConfirmations;
        bool isBnb;
    }
    
    IBEP20 public immutable sdoge;
    
    address[] public owners;
    mapping(address => bool) public isOwner;
    uint8 public numConfirmationsRequired;

    // mapping from tx index => owner => bool
    mapping(uint => mapping(address => bool)) public isConfirmed;

    Transaction[] public transactions;
    
    event Deposit(address indexed sender, uint256 amount, uint256 balance);
    
    event SubmitTx(
        address indexed owner,
        uint256 indexed txIndex,
        address indexed to,
        uint256 value,
        bytes data,
        bool isBnb
    );
    
    event ConfirmTx(address indexed owner, uint256 indexed txIndex);
    
    event RevokeConfirmation(address indexed owner, uint256 indexed txIndex);
    
    event ExecuteTx(address indexed owner, uint256 indexed txIndex);

    modifier onlyOwner() {
        require(isOwner[msg.sender], "ScholarDogeTreasury: not owner");
        _;
    }

    modifier txExists(uint _txIndex) {
        require(
            _txIndex < transactions.length,
            "ScholarDogeTreasury: tx does not exist"
        );
        _;
    }

    modifier notExecuted(uint _txIndex) {
        require(
            !transactions[_txIndex].executed,
            "ScholarDogeTreasury: tx already executed"
        );
        _;
    }

    modifier notConfirmed(uint _txIndex) {
        require(
            !isConfirmed[_txIndex][msg.sender],
            "ScholarDogeTreasury: tx already confirmed"
        );
        _;
    }

    constructor(address[] memory _owners, address _sdoge) {
        require(
            _owners.length > 0,
            "ScholarDogeTreasury: owners required"
        );

        for (uint i = 0; i < _owners.length; i++) {
            address owner = _owners[i];

            require(
                owner != address(0),
                "ScholarDogeTreasury: invalid owner"
            );
            require(
                !isOwner[owner],
                "ScholarDogeTreasury: owner not unique"
            );

            isOwner[owner] = true;
            owners.push(owner);
        }

        numConfirmationsRequired = uint8(_owners.length) / 2 + 1;
        sdoge = IBEP20(_sdoge);
    }

    receive() payable external {
        emit Deposit(msg.sender, msg.value, address(this).balance);
    }

    function submitTx(
        address _to,
        uint _value,
        bytes memory _data,
        bool _isBnb
    )
        public
        onlyOwner
    {
        uint txIndex = transactions.length;

        transactions.push(Transaction({
            to: _to,
            value: _value,
            data: _data,
            executed: false,
            numConfirmations: 0,
            isBnb: _isBnb
        }));

        emit SubmitTx(msg.sender, txIndex, _to, _value, _data, _isBnb);
    }
    
    function submitAddOwnerTx(address _target)
        public
        onlyOwner
    {
        uint txIndex = transactions.length;

        transactions.push(Transaction({
            to: _target,
            value: 0,
            data: "",
            executed: false,
            numConfirmations: 0,
            isBnb: false
        }));

        emit SubmitTx(msg.sender, txIndex, _target, 0, "", false);
    }

    function confirmTx(uint _txIndex)
        public
        onlyOwner
        txExists(_txIndex)
        notExecuted(_txIndex)
        notConfirmed(_txIndex)
    {
        Transaction storage transaction = transactions[_txIndex];
        transaction.numConfirmations += 1;
        isConfirmed[_txIndex][msg.sender] = true;

        emit ConfirmTx(msg.sender, _txIndex);
    }

    function executeTransaction(uint _txIndex)
        public
        onlyOwner
        txExists(_txIndex)
        notExecuted(_txIndex)
    {
        Transaction storage transaction = transactions[_txIndex];

        require(
            transaction.numConfirmations >= numConfirmationsRequired,
            "ScholarDogeTreasury: cannot execute tx"
        );

        transaction.executed = true;
        
        if (transaction.value == 0) {
            // If no value => adding an owner
            owners.push(transaction.to);
            
            numConfirmationsRequired = uint8(owners.length) / 2 + 1;
        } else if (transaction.isBnb) {
            // Sending bnb
            (bool success, )
                = transaction.to.call{value: transaction.value}(transaction.data);
            
            require(success, "ScholarDogeTreasury: tx failed");
        } else {
            // Sending $SDOGE
            bool success
                = sdoge.transfer(transaction.to, transaction.value);
                
            require(success, "ScholarDogeTreasury: tx failed");
        }

        emit ExecuteTx(msg.sender, _txIndex);
    }

    function revokeConfirmation(uint _txIndex)
        public
        onlyOwner
        txExists(_txIndex)
        notExecuted(_txIndex)
    {
        Transaction storage transaction = transactions[_txIndex];

        require(
            isConfirmed[_txIndex][msg.sender],
            "ScholarDogeTreasury: tx not confirmed"
        );

        transaction.numConfirmations -= 1;
        isConfirmed[_txIndex][msg.sender] = false;

        emit RevokeConfirmation(msg.sender, _txIndex);
    }

    function getOwners() public view returns (address[] memory) {
        return owners;
    }

    function getTransactionCount() public view returns (uint) {
        return transactions.length;
    }

    function getTransaction(uint _txIndex)
        public
        view
        returns (
            address to,
            uint value,
            bytes memory data,
            bool executed,
            uint numConfirmations,
            bool isBnb)
    {
        Transaction storage transaction = transactions[_txIndex];

        return (
            transaction.to,
            transaction.value,
            transaction.data,
            transaction.executed,
            transaction.numConfirmations,
            transaction.isBnb
        );
    }
}
