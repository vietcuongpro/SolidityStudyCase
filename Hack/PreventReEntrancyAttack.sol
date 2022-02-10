pragma solidity ^0.8.0;

/*
    Imagine having no modifier 'noReEntrancy', contract EtherStorage can be attacked by
    contract Attack

    E.g.: Eve call Attack.attack, it call EtherStorage.withdraw(),
    -> it send ether to contract Attack, fallback() is trigger
    -> inside fallback it call withdraw => loop to withdraw all ether to Eve
*/

// SPDX-License-Identifier: UNLICENSED

contract EtherStorage {
    mapping (address => uint) public balances;

    function deposit() public payable {
        balances[msg.sender] += msg.value;
    }

    bool internal locked;

    modifier noReEntrancy() {
        require(!locked, "No Re-entrancy");
        locked = true;
        _;
        locked = false;
    }

    // having this modifier prevent re-enter again
    function withdraw() public noReEntrancy {
        uint bal = balances[msg.sender];
        require(bal > 0, "Having no ether");

        (bool sent,) = (msg.sender).call{value: bal}("");
        require(sent, "Failed to sent Ether");

        balances[msg.sender] = 0;
    }

    function checkBalance() public view returns (uint) {
        return address(this).balance;
    }
}

contract Attack {
    EtherStorage public etherStore;

    constructor(address _etherStorage) {
        etherStore = EtherStorage(_etherStorage);
    }

    // fallback trigger when EtherStorage send ether to this contract
    fallback() external payable {
        if (etherStore.checkBalance() >= 1 ether) {
            etherStore.withdraw();
        }
    }

    function attack() external payable {
        require(msg.value >= 1 ether, "Need at least 1 ether");
        etherStore.deposit{value: 1 ether}();
        etherStore.withdraw();
    }

    function checkBalance() public view returns (uint) {
        return address(this).balance;
    }
}